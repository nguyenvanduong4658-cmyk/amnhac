import 'package:flutter/material.dart';
import '../../services/player_service.dart';
import '../../models/recently_played.dart';
import '../widgets/nav_widget.dart';
import '../mainpage.dart';
import 'music_player_screen.dart';

class RecentlyPlayedPage extends StatefulWidget {
  const RecentlyPlayedPage({super.key});

  @override
  State<RecentlyPlayedPage> createState() => _RecentlyPlayedPageState();
}

class _RecentlyPlayedPageState extends State<RecentlyPlayedPage> {
  String _selectedFilter = "Nhạc";

  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compare = DateTime(date.year, date.month, date.day);
    final diff = today.difference(compare).inDays;

    if (diff == 0) {
      return "Hôm nay";
    } else if (diff == 1) {
      return "Hôm qua";
    }

    final weekdays = {
      DateTime.monday: "Th 2",
      DateTime.tuesday: "Th 3",
      DateTime.wednesday: "Th 4",
      DateTime.thursday: "Th 5",
      DateTime.friday: "Th 6",
      DateTime.saturday: "Th 7",
      DateTime.sunday: "CN",
    };

    final wk = weekdays[date.weekday] ?? "";
    return "$wk, ${date.day} thg ${date.month}, ${date.year}";
  }

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

  @override
  Widget build(BuildContext context) {
    final player = PlayerService();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Gần đây",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: player,
              builder: (context, child) {
                // Filter and group items
                final List<RecentlyPlayedItem> filteredItems = player.recentlyPlayedList.where((item) {
                  if (_selectedFilter == "Nhạc") {
                    return true; // We can show all categories under "Nhạc" filter for now
                  }
                  return true;
                }).toList();

                // Force sort by playedAt descending to ensure newest songs appear on top immediately
                filteredItems.sort((a, b) => b.playedAt.compareTo(a.playedAt));

                final Map<String, List<RecentlyPlayedItem>> grouped = {};
                for (final item in filteredItems) {
                  final dateKey = _formatHeaderDate(item.playedAt);
                  if (!grouped.containsKey(dateKey)) {
                    grouped[dateKey] = [];
                  }
                  grouped[dateKey]!.add(item);
                }

                final groupKeys = grouped.keys.toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text(
                      "Chưa có bài hát đã phát gần đây.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 150), // spacer for bottom navigation and player
                  itemCount: groupKeys.length + 1, // +1 for the filter pill row
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Filter pill row
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1ED760),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Nhạc",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final key = groupKeys[index - 1];
                    final items = grouped[key]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Text(
                            key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...items.map((item) => _buildListItem(context, item, player)),
                      ],
                    );
                  },
                );
              },
            ),

            // Floating Mini Player Overlay
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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      song.albumArt,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey,
                                        width: 48,
                                        height: 48,
                                        child: const Icon(Icons.music_note, color: Colors.white),
                                      ),
                                    ),
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
                                    icon: Icon(
                                      player.isSongLiked(song) ? Icons.check_circle : Icons.add_circle_outline,
                                      color: player.isSongLiked(song) ? const Color(0xFF1ED760) : Colors.white,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      player.toggleLikeSong(song);
                                    },
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
                              child: Container(
                                color: Colors.white,
                              ),
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1, // No tab highlighted on this sub page
        onTap: (index) {
          Navigator.pop(context); // Pop back to MainPage
          MainPage.activeState?.changeTab(index); // Change active tab
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, RecentlyPlayedItem item, PlayerService player) {
    final isArtist = item.type == 'artist';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isArtist ? null : BorderRadius.circular(4),
          color: const Color(0xFF242424),
        ),
        clipBehavior: Clip.antiAlias,
        child: item.imageUrl.isNotEmpty
            ? Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.music_note,
                  color: Colors.white30,
                  size: 28,
                ),
              )
            : const Icon(
                Icons.image,
                color: Colors.white24,
                size: 28,
              ),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            if (item.hasCheck) ...[
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1ED760),
                size: 14,
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                item.subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      trailing: item.type == 'song'
          ? IconButton(
              icon: Icon(
                player.isSongDownloaded(item.title)
                    ? Icons.check_circle
                    : Icons.arrow_circle_down_outlined,
                color: player.isSongDownloaded(item.title)
                    ? const Color(0xFF1ED760)
                    : Colors.white54,
                size: 22,
              ),
              onPressed: () {
                player.toggleDownloadSong(item.title);
                final isNowDownloaded = player.isSongDownloaded(item.title);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isNowDownloaded
                          ? "Đã tải xuống thiết bị: ${item.title}"
                          : "Đã gỡ tệp tải xuống của: ${item.title}",
                    ),
                    backgroundColor: const Color(0xFF1ED760),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            )
          : (item.type == 'playlist'
              ? const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                  size: 24,
                )
              : const Icon(
                  Icons.arrow_circle_down_outlined,
                  color: Colors.white54,
                  size: 22,
                )),
      onTap: () {
        if (item.type == 'song') {
          // If song, find it in player playlist and play
          final songMatch = player.playlist.firstWhere(
            (s) => s.title.toLowerCase() == item.title.toLowerCase(),
            orElse: () => player.playlist.first,
          );
          player.playSong(songMatch);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Đang phát bài hát: ${songMatch.title}"),
              backgroundColor: const Color(0xFF1ED760),
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          // Else show SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Đang phát danh mục: ${item.title}"),
              backgroundColor: const Color(0xFF1ED760),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }
}
