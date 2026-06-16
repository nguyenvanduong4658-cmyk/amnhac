import 'package:flutter/material.dart';
import '../../services/player_service.dart';
import 'playlist_detail_screen.dart';

class CreateScreen extends StatefulWidget {
  final VoidCallback onPlaylistCreated;

  const CreateScreen({super.key, required this.onPlaylistCreated});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Đặt tên cho danh sách phát của bạn.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: "Danh sách phát của tôi",
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: false,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38, width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1ED760), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        _controller.clear();
                      },
                      child: const Text(
                        "Hủy",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1ED760),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        final name = _controller.text.trim();
                        if (name.isNotEmpty) {
                          await PlayerService().addCustomPlaylist(name);
                          if (mounted) {
                            _controller.clear();
                            // Navigate to playlist detail screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistDetailScreen(playlistName: name),
                              ),
                            ).then((_) {
                              // When coming back from detail, switch to Library tab
                              widget.onPlaylistCreated();
                            });
                          }
                        }
                      },
                      child: const Text(
                        "Tạo",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
