import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/player_service.dart';
import '../../models/song.dart';
import '../../models/artist.dart';
import '../widgets/spinning_album_art.dart';
import 'music_player_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistName;

  const ArtistDetailScreen({super.key, required this.artistName});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  bool _isFollowing = true;

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

  void _showArtistMoreOptions(BuildContext context, PlayerService player) {
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  widget.artistName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: Icon(
                  _isFollowing ? Icons.person_remove_outlined : Icons.person_add_alt_1_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  _isFollowing ? "Bỏ theo dõi nghệ sĩ" : "Theo dõi nghệ sĩ",
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _isFollowing = !_isFollowing;
                  });
                  if (_isFollowing) {
                    player.addFollowedArtist(widget.artistName, player.getArtistImageUrl(widget.artistName));
                  } else {
                    player.removeFollowedArtist(widget.artistName);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFollowing ? "Đã theo dõi nghệ sĩ ${widget.artistName}" : "Đã bỏ theo dõi nghệ sĩ ${widget.artistName}"),
                      backgroundColor: const Color(0xFF1ED760),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.white),
                title: const Text("Chia sẻ nghệ sĩ", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Clipboard.setData(ClipboardData(text: "https://open.spotify.com/artist/${widget.artistName.replaceAll(' ', '_')}"));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đã sao chép liên kết chia sẻ nghệ sĩ vào khay nhớ tạm!"),
                        backgroundColor: Color(0xFF1ED760),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, PlayerService player, String songTitle) {
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
                  "Thêm vào danh sách phát",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              if (player.customPlaylists.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    "Chưa có danh sách phát nào.",
                    style: TextStyle(color: Colors.white30),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: player.customPlaylists.length,
                    itemBuilder: (c, idx) {
                      final playlistName = player.customPlaylists[idx];
                      final isAdded = player.isSongInPlaylist(playlistName, songTitle);
                      return ListTile(
                        leading: const Icon(Icons.music_note, color: Colors.white),
                        title: Text(playlistName, style: const TextStyle(color: Colors.white)),
                        trailing: isAdded
                            ? const Icon(Icons.check, color: Color(0xFF1ED760))
                            : const Icon(Icons.add, color: Colors.white54),
                        onTap: () async {
                          if (isAdded) {
                            await player.removeSongFromPlaylist(playlistName, songTitle);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Đã xóa khỏi danh sách phát $playlistName"),
                                  backgroundColor: Colors.redAccent,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          } else {
                            await player.addSongToPlaylist(playlistName, songTitle);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Đã thêm vào danh sách phát $playlistName"),
                                  backgroundColor: const Color(0xFF1ED760),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          }
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
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
        final isLiked = player.isSongLiked(song);
        final isDownloaded = player.isSongDownloaded(song.title);
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
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    song.albumArt,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.white),
                title: const Text("Phát bài hát", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  player.playSong(song);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text("Thêm vào danh sách phát", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddToPlaylistSheet(context, player, song.title);
                },
              ),
              ListTile(
                leading: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? const Color(0xFF1ED760) : Colors.white,
                ),
                title: Text(
                  isLiked ? "Bỏ thích bài hát" : "Thích bài hát",
                  style: TextStyle(color: isLiked ? const Color(0xFF1ED760) : Colors.white),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  player.toggleLikeSong(song);
                },
              ),
              ListTile(
                leading: Icon(
                  isDownloaded ? Icons.download_done : Icons.download_outlined,
                  color: isDownloaded ? const Color(0xFF1ED760) : Colors.white,
                ),
                title: Text(
                  isDownloaded ? "Xóa nội dung tải xuống" : "Tải xuống bài hát",
                  style: TextStyle(color: isDownloaded ? const Color(0xFF1ED760) : Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await player.toggleDownloadSong(song.title);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isDownloaded ? "Đã xóa nội dung tải xuống" : "Đã tải xuống bài hát"),
                        backgroundColor: const Color(0xFF1ED760),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.white),
                title: const Text("Chia sẻ bài hát", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Clipboard.setData(ClipboardData(text: "https://open.spotify.com/track/${song.title.replaceAll(' ', '_')}"));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đã sao chép liên kết bài hát vào khay nhớ tạm!"),
                        backgroundColor: Color(0xFF1ED760),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthlyListeners(String name) {
    if (name.contains("Sơn Tùng")) return "2.443.918 người nghe hằng tháng";
    if (name.contains("tlinh")) return "1.890.224 người nghe hằng tháng";
    if (name.contains("MCK")) return "2.105.748 người nghe hằng tháng";
    if (name.contains("HIEUTHUHAI")) return "2.516.330 người nghe hằng tháng";
    if (name.contains("Wren Evans")) return "1.954.210 người nghe hằng tháng";
    if (name.contains("GREY D")) return "1.789.345 người nghe hằng tháng";
    final hash = name.hashCode.abs();
    final count = (hash % 1500000) + 500000;
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return "${count.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')} người nghe hằng tháng";
  }

  String _getSongPlayCount(String title) {
    final hash = title.hashCode.abs();
    final millions = (hash % 85) + 5;
    final thousands = hash % 1000;
    final hundreds = (hash ~/ 10) % 1000;
    final formattedThousands = thousands.toString().padLeft(3, '0');
    final formattedHundreds = hundreds.toString().padLeft(3, '0');
    return "$millions.$formattedThousands.$formattedHundreds";
  }

  Widget _buildArtistBannerImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF282828)),
      );
    } else {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF282828)),
        );
      }
    }
    return Container(color: const Color(0xFF282828));
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerService();
    final artist = player.followedArtists.firstWhere(
      (a) => a.name == widget.artistName,
      orElse: () => Artist(
        name: widget.artistName,
        imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80",
      ),
    );

    // Get songs for this artist (match artist name in song.artist or song.subtitle or song.title)
    final artistSongs = player.playlist.where((s) {
      final nameLower = widget.artistName.toLowerCase();
      return s.artist.toLowerCase().contains(nameLower) ||
          s.subtitle.toLowerCase().contains(nameLower) ||
          s.title.toLowerCase().contains(nameLower);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: player,
            builder: (context, child) {
              return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  floating: false,
                  elevation: 0,
                  backgroundColor: const Color(0xFF121212),
                  leading: const SizedBox.shrink(), // Custom lead back button is placed over Stack
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildArtistBannerImage(player.getArtistImageUrl(widget.artistName, fallbackUrl: artist.imageUrl)),
                        // Black gradient overlay bottom
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0xFF121212)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.4, 1.0],
                            ),
                          ),
                        ),
                        // Dark overlay top for back button readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.3],
                            ),
                          ),
                        ),
                        // Text Overlay at bottom of image
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Verified badge
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFF1ED760),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Do Spotify xác minh",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Artist Name
                              Text(
                                widget.artistName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 8.0,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              // Listener count
                              Text(
                                _getMonthlyListeners(widget.artistName),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Controls Row: Follow buttons, shuffle, play
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          // Small profile / album icon
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _buildArtistBannerImage(artist.imageUrl),
                          ),
                          const SizedBox(width: 16),
                          // Follow button
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isFollowing = !_isFollowing;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isFollowing
                                        ? "Đã theo dõi ${widget.artistName}"
                                        : "Đã bỏ theo dõi ${widget.artistName}",
                                  ),
                                  backgroundColor: const Color(0xFF1ED760),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _isFollowing ? Colors.white70 : Colors.white38),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Text(
                              _isFollowing ? "Đang theo dõi" : "Theo dõi",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          // More options ... icon
                          IconButton(
                            icon: const Icon(Icons.more_horiz, color: Colors.white70, size: 24),
                            onPressed: () => _showArtistMoreOptions(context, player),
                          ),
                          const Spacer(),
                          // Shuffle icon
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: player.isShuffled ? const Color(0xFF1ED760) : Colors.white54,
                              size: 22,
                            ),
                            onPressed: () => player.toggleShuffle(),
                          ),
                          const SizedBox(width: 16),
                          // Play FAB button
                          Builder(
                            builder: (context) {
                              final isArtistPlaying = player.isPlaying &&
                                  artistSongs.isNotEmpty &&
                                  artistSongs.any((s) => s.title == player.currentSong.title);

                              return GestureDetector(
                                onTap: () {
                                  if (artistSongs.isEmpty) return;
                                  if (isArtistPlaying) {
                                    player.pause();
                                  } else {
                                    final index = artistSongs.indexWhere((s) => s.title == player.currentSong.title);
                                    if (index != -1) {
                                      player.play();
                                    } else {
                                      if (player.isShuffled) {
                                        final randomSongs = List<Song>.from(artistSongs)..shuffle();
                                        player.playSong(randomSongs.first);
                                      } else {
                                        player.playSong(artistSongs.first);
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
                                    isArtistPlaying ? Icons.pause : Icons.play_arrow,
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

                    // Tabs Row: Nhạc
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nhạc",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 44,
                                height: 3,
                                color: const Color(0xFF1ED760),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // "Phổ biến" Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        "Phổ biến",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Numbered popular songs list
                    if (artistSongs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "Chưa có bài hát nào cho nghệ sĩ này.",
                            style: TextStyle(color: Colors.white30, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: artistSongs.length,
                        itemBuilder: (context, index) {
                          final song = artistSongs[index];
                          final isPlaying = player.isPlaying && player.currentSong.title == song.title;

                          return InkWell(
                            onTap: () {
                              player.playSong(song);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              child: Row(
                                children: [
                                  // Number index
                                  SizedBox(
                                    width: 20,
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        color: isPlaying ? const Color(0xFF1ED760) : Colors.white54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                  // Title + Listen count
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
                                          _getSongPlayCount(song.title),
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // More option vertical icon
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                                    onPressed: () => _showSongOptions(context, song, player),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 120), // Mini player spacer
                  ],
                ),
              ),
            ),
              );
            },
          ),

          // Floating Back Arrow (translucent background matching Spotify)
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 8,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          // Mini Player overlay matching main screen
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
    );
  }
}
