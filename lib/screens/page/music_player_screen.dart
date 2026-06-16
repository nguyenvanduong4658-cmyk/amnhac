import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/player_service.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _playPauseAnimationController;
  final ScrollController _lyricScrollController = ScrollController();
  bool _shuffle = false;
  bool _repeat = false;

  @override
  void initState() {
    super.initState();
    _playPauseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    if (PlayerService().isPlaying) {
      _playPauseAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _playPauseAnimationController.dispose();
    _lyricScrollController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _scrollToActiveLyric(int activeIndex) {
    if (_lyricScrollController.hasClients && activeIndex >= 0) {
      final targetOffset = activeIndex * 48.0;
      _lyricScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
        } else {
          _playPauseAnimationController.reverse();
        }

        int activeLyricIndex = -1;
        if (song.lyrics.isNotEmpty && player.totalDuration.inSeconds > 0) {
          final secondsPerLyric = player.totalDuration.inSeconds / song.lyrics.length;
          if (secondsPerLyric > 0) {
            final double idxDouble = player.currentPosition.inSeconds / secondsPerLyric;
            if (idxDouble.isFinite) {
              activeLyricIndex = idxDouble.floor();
            }
          }
          if (activeLyricIndex >= song.lyrics.length) {
            activeLyricIndex = song.lyrics.length - 1;
          }
          if (activeLyricIndex >= 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToActiveLyric(activeLyricIndex);
            });
          }
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
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Album Artwork
                      Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        height: MediaQuery.of(context).size.width * 0.82,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
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
                              color: _shuffle ? const Color(0xFF1ED760) : Colors.white,
                              size: 26,
                            ),
                            onPressed: () {
                              setState(() {
                                _shuffle = !_shuffle;
                              });
                            },
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
                              color: _repeat ? const Color(0xFF1ED760) : Colors.white,
                              size: 26,
                            ),
                            onPressed: () {
                              setState(() {
                                _repeat = !_repeat;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Lyrics Container
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: song.themeColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Lời bài hát",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white12,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.open_in_full, size: 10, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text(
                                              "Mở rộng",
                                              style: TextStyle(color: Colors.white, fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: _lyricScrollController,
                                      itemCount: song.lyrics.length,
                                      itemExtent: 48.0,
                                      itemBuilder: (context, i) {
                                        final isAct = i == activeLyricIndex;
                                        return Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            song.lyrics[i],
                                            style: TextStyle(
                                              color: isAct ? Colors.white : Colors.white24,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
