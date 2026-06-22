import 'package:flutter/material.dart';
import '../screens/widgets/nav_widget.dart';
import '../screens/widgets/drawer_widget.dart';
import '../screens/widgets/spinning_album_art.dart';
import '../screens/page/home_screen.dart';
import '../screens/page/search_screen.dart';
import '../screens/page/library_screen.dart';
import '../screens/page/premium_screen.dart';
import '../screens/page/create_screen.dart';
import '../screens/page/music_player_screen.dart';
import '../services/player_service.dart';

class MainPage extends StatefulWidget {
  static final GlobalKey<_MainPageState> mainPageKey = GlobalKey<_MainPageState>();
  static _MainPageState? activeState;

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    MainPage.activeState = this;
  }

  @override
  void dispose() {
    if (MainPage.activeState == this) {
      MainPage.activeState = null;
    }
    super.dispose();
  }

  // Let's declare pages list dynamically to pass local callbacks
  List<Widget> get pages => [
        const HomePage(),
        const SearchScreen(),
        const LibraryScreen(),
        const PremiumScreen(),
        CreateScreen(
          onPlaylistCreated: () {
            changeTab(2); // Redirect to Library Screen (tab index 2)
          },
        ),
      ];

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
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

  void _showDevicesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Kết nối với thiết bị",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Active Device
                ListTile(
                  leading: const Icon(Icons.phone_android, color: Color(0xFF1ED760)),
                  title: const Text("Điện thoại này", style: TextStyle(color: Color(0xFF1ED760), fontWeight: FontWeight.bold)),
                  subtitle: const Text("Đang phát trên loa điện thoại", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: const Icon(Icons.volume_up, color: Color(0xFF1ED760)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(color: Colors.white10),
                
                // Other simulated options
                ListTile(
                  leading: const Icon(Icons.speaker, color: Colors.white70),
                  title: const Text("Loa Bluetooth phòng khách", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Nhấn để kết nối", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đang kết nối với Loa Bluetooth phòng khách..."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.tv, color: Colors.white70),
                  title: const Text("Smart TV Phòng ngủ", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Nhấn để truyền tín hiệu", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đang truyền tín hiệu sang Smart TV..."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      body: Stack(
        children: [
          // Indexed tabs stack
          IndexedStack(
            index: currentIndex,
            children: pages,
          ),

          // Floating Mini Player Overlay
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: AnimatedBuilder(
              animation: PlayerService(),
              builder: (context, child) {
                final player = PlayerService();
                final song = player.currentSong;
                double progressPercent = player.totalDuration.inSeconds > 0
                    ? player.currentPosition.inSeconds / player.totalDuration.inSeconds
                    : 0.0;
                if (progressPercent < 0.0) progressPercent = 0.0;
                if (progressPercent > 1.0) progressPercent = 1.0;

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
                                // Album cover
                                SpinningAlbumArt(
                                  imageUrl: song.albumArt,
                                  isPlaying: player.isPlaying,
                                  size: 48,
                                  isCircle: true,
                                ),
                                const SizedBox(width: 10),
                                // Metadata
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
                                // Cast Devices Trigger
                                IconButton(
                                  icon: const Icon(Icons.devices, color: Colors.white, size: 20),
                                  onPressed: _showDevicesSheet,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 16),
                                // Dynamic Like/Add button
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
                                // Play/Pause trigger
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
                        // Progress line bar
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: changeTab,
      ),
    );
  }
}
