import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/player_service.dart';
import 'artist_detail_screen.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> with TickerProviderStateMixin {
  late AnimationController _playPauseAnimationController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _playPauseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (PlayerService().isPlaying) {
      _playPauseAnimationController.forward();
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _playPauseAnimationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
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

  void _showPlayerOptions(BuildContext context, PlayerService player) {
    final song = player.currentSong;
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
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: const Text("Xem thông tin nghệ sĩ", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx); // Close sheet
                  Navigator.pop(context); // Close player screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistDetailScreen(artistName: song.artist),
                    ),
                  );
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PlayerService(),
      builder: (context, child) {
        final player = PlayerService();
        final song = player.currentSong;

        double maxVal = player.totalDuration.inSeconds.toDouble();
        if (maxVal <= 0.0) maxVal = 1.0;
        double currentVal = player.currentPosition.inSeconds.toDouble();
        if (currentVal < 0.0) currentVal = 0.0;
        if (currentVal > maxVal) currentVal = maxVal;

        if (player.isPlaying) {
          _playPauseAnimationController.forward();
          _rotationController.repeat();
        } else {
          _playPauseAnimationController.reverse();
          _rotationController.stop(canceled: false);
        }

        return Scaffold(
          body: Stack(
            children: [
              Container(
                color: song.themeColor.withOpacity(0.8),
              ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(song.albumArt),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Column(
                            children: [
                              const Text(
                                "ĐANG PHÁT TỪ DANH SÁCH",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.bannerText.replaceAll('\n', ' '),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () => _showPlayerOptions(context, player),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Album Artwork (CD / Vinyl rotation transition)
                      RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.82,
                          height: MediaQuery.of(context).size.width * 0.82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 25,
                                spreadRadius: 2,
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(song.albumArt),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Song details & actions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.artist,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              player.isSongLiked(song) ? Icons.check_circle : Icons.add_circle_outline,
                              color: player.isSongLiked(song) ? const Color(0xFF1ED760) : Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              player.toggleLikeSong(song);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.1),
                        ),
                        child: Slider(
                          value: currentVal,
                          min: 0.0,
                          max: maxVal,
                          onChanged: (value) {
                            player.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      // Time Labels
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(player.currentPosition),
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(player.totalDuration),
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Audio Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: player.isShuffled ? const Color(0xFF1ED760) : Colors.white,
                              size: 26,
                            ),
                            onPressed: () => player.toggleShuffle(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                            onPressed: () => player.previous(),
                          ),
                          GestureDetector(
                            onTap: () => player.togglePlay(),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: AnimatedIcon(
                                  icon: AnimatedIcons.play_pause,
                                  progress: _playPauseAnimationController,
                                  color: Colors.black,
                                  size: 38,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                            onPressed: () => player.next(),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.repeat,
                              color: player.isRepeating ? const Color(0xFF1ED760) : Colors.white,
                              size: 26,
                            ),
                            onPressed: () => player.toggleRepeating(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
