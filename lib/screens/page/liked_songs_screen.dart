import 'package:flutter/material.dart';
import '../../services/player_service.dart';
import '../../models/song.dart';
import '../widgets/spinning_album_art.dart';
import 'music_player_screen.dart';

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {

  void _openFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.95,
        child: MusicPlayerScreen(),
      ),
    );
  }

  void _showDevicesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "Kết nối với thiết bị",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: const Icon(Icons.phone_android, color: Color(0xFF1ED760)),
                title: const Text("Điện thoại này (Thiết bị hiện tại)", style: TextStyle(color: Color(0xFF1ED760))),
                trailing: const Icon(Icons.volume_up, color: Color(0xFF1ED760)),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.speaker, color: Colors.white),
                title: const Text("Loa Bluetooth phòng khách", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đang kết nối với Loa Bluetooth..."),
                      backgroundColor: Color(0xFF1ED760),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.tv, color: Colors.white),
                title: const Text("Tivi thông minh (Smart TV)", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đang truyền phát sang Smart TV..."),
                      backgroundColor: Color(0xFF1ED760),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSongsDialog(BuildContext context, PlayerService player) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final unlikedSongs = player.playlist
                .where((s) => !player.isSongLiked(s))
                .toList();

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                "Thêm bài hát đã thích",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: unlikedSongs.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          "Tất cả bài hát đều đã được thích!",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: unlikedSongs.length,
                        itemBuilder: (ctx, index) {
                          final song = unlikedSongs[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                song.albumArt,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[800],
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.music_note, color: Colors.white30),
                                ),
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1ED760)),
                              onPressed: () async {
                                await player.toggleLikeSong(song);
                                setDialogState(() {}); // Refresh state in dialog
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Đã thích bài hát: ${song.title}"),
                                      backgroundColor: const Color(0xFF1ED760),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Xong", style: TextStyle(color: Color(0xFF1ED760), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSongOptions(BuildContext context, Song song, PlayerService player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.white),
                title: const Text("Phát bài hát", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  player.playSong(song, queue: player.playlist.where((s) => player.isSongLiked(s)).toList());
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.redAccent),
                title: const Text("Xóa khỏi bài hát đã thích", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  player.toggleLikeSong(song);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã bỏ thích \"${song.title}\""),
                      backgroundColor: Colors.redAccent,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerService();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: player,
              builder: (context, child) {
                // Get all songs currently liked by the user
                final likedSongs = player.playlist
                    .where((s) => player.isSongLiked(s))
                    .toList();

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Back button + Header Title Info
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF382088), Color(0xFF121212)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1.0],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Bài hát đã thích",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${likedSongs.length} bài hát",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Controls Row: Album stack card, download icon, spacer, shuffle, play button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            // Liked Songs Mini Album stack card
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF450E4E), Color(0xFFC43A30)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(Icons.favorite, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 16),
                            // Download Icon
                            IconButton(
                              icon: Icon(
                                likedSongs.isNotEmpty && likedSongs.every((s) => player.isSongDownloaded(s.title))
                                    ? Icons.arrow_circle_down
                                    : Icons.arrow_circle_down_outlined,
                                color: likedSongs.isNotEmpty && likedSongs.every((s) => player.isSongDownloaded(s.title))
                                    ? const Color(0xFF1ED760)
                                    : Colors.white60,
                                size: 24,
                              ),
                              onPressed: () async {
                                if (likedSongs.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Chưa có bài hát đã thích nào để tải xuống"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                final allDownloaded = likedSongs.every((s) => player.isSongDownloaded(s.title));
                                final nextState = !allDownloaded;
                                for (final song in likedSongs) {
                                  if (player.isSongDownloaded(song.title) != nextState) {
                                    await player.toggleDownloadSong(song.title);
                                  }
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(nextState ? "Đã tải xuống tất cả bài hát đã thích!" : "Đã xóa nội dung tải xuống!"),
                                      backgroundColor: const Color(0xFF1ED760),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const Spacer(),
                            // Shuffle Button
                            IconButton(
                              icon: Icon(
                                Icons.shuffle,
                                color: player.isShuffled ? const Color(0xFF1ED760) : Colors.white54,
                                size: 22,
                              ),
                              onPressed: () => player.toggleShuffle(),
                            ),
                            const SizedBox(width: 16),
                            // Green Circle Play button
                            Builder(
                              builder: (context) {
                                final isLikedPlaying = player.isPlaying &&
                                    likedSongs.isNotEmpty &&
                                    likedSongs.any((s) => s.title == player.currentSong.title);

                                return GestureDetector(
                                  onTap: () {
                                    if (likedSongs.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Danh sách bài hát đã thích rỗng!"),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }

                                    if (isLikedPlaying) {
                                      player.pause();
                                    } else {
                                      final index = likedSongs.indexWhere((s) => s.title == player.currentSong.title);
                                      if (index != -1) {
                                        player.play();
                                      } else {
                                        if (player.isShuffled) {
                                          final randomSongs = List<Song>.from(likedSongs)..shuffle();
                                          player.playSong(randomSongs.first, queue: randomSongs);
                                        } else {
                                          player.playSong(likedSongs.first, queue: likedSongs);
                                        }
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF1ED760),
                                    ),
                                    child: Icon(
                                      isLikedPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // "Thêm vào danh sách phát này" (Add songs to this playlist) Tile
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF282828),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 24),
                          ),
                          title: const Text(
                            "Thêm vào danh sách phát này",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => _showAddSongsDialog(context, player),
                        ),
                      ),
                    ),

                    // List of Liked Songs
                    if (likedSongs.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 8.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final song = likedSongs[index];
                              final isPlaying = player.isPlaying && player.currentSong.title == song.title;

                              return InkWell(
                                onTap: () => player.playSong(song, queue: player.playlist.where((s) => player.isSongLiked(s)).toList()),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      // Album Art
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          song.albumArt,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: const Color(0xFF282828),
                                            width: 48,
                                            height: 48,
                                            child: const Icon(Icons.music_note, color: Colors.white24),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Title + Artist
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              song.title,
                                              style: TextStyle(
                                                color: isPlaying ? const Color(0xFF1ED760) : Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              song.artist,
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Three dots options button
                                      IconButton(
                                        icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                                        onPressed: () => _showSongOptions(context, song, player),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: likedSongs.length,
                          ),
                        ),
                      )
                    else
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 64.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite_border, color: Colors.white24, size: 48),
                                SizedBox(height: 16),
                                Text(
                                  "Chưa có bài hát đã thích nào.",
                                  style: TextStyle(color: Colors.white30, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Spacer for mini player
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 150),
                    ),
                  ],
                );
              },
            ),

            // Mini Player Overlay
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: AnimatedBuilder(
                animation: player,
                builder: (context, child) {
                  final song = player.currentSong;
                  final progressPercent = player.totalDuration.inSeconds > 0
                      ? player.currentPosition.inSeconds / player.totalDuration.inSeconds
                      : 0.0;

                  return GestureDetector(
                    onTap: _openFullPlayer,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: song.themeColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  SpinningAlbumArt(
                                    imageUrl: song.albumArt,
                                    isPlaying: player.isPlaying,
                                    size: 48,
                                    isCircle: true,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          song.artist,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.devices, color: Colors.white, size: 20),
                                    onPressed: () => _showDevicesSheet(context),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: Icon(
                                      player.isSongLiked(song) ? Icons.check_circle : Icons.add_circle_outline,
                                      color: player.isSongLiked(song) ? const Color(0xFF1ED760) : Colors.white,
                                      size: 22,
                                    ),
                                    onPressed: () => player.toggleLikeSong(song),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: Icon(
                                      player.isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: () => player.togglePlay(),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 2.5,
                            width: double.infinity,
                            color: Colors.white24,
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progressPercent.clamp(0.0, 1.0),
                              child: Container(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
