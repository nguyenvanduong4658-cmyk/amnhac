import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/player_service.dart';
import '../../models/song.dart';
import '../widgets/spinning_album_art.dart';
import 'music_player_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistName;

  const PlaylistDetailScreen({super.key, required this.playlistName});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late String _currentPlaylistName;
  late TextEditingController _nameController;
  final TextEditingController _searchController = TextEditingController();
  String _playlistSearchQuery = "";
  late ScrollController _scrollController;
  bool _isEditMode = false;
  String _sortOption = "default"; // 'default', 'title', 'artist'

  @override
  void initState() {
    super.initState();
    _currentPlaylistName = widget.playlistName;
    _nameController = TextEditingController(text: _currentPlaylistName);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _pickCoverImage(PlayerService player) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        await player.setPlaylistCover(_currentPlaylistName, picked.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã cập nhật ảnh bìa danh sách phát!"),
              backgroundColor: Color(0xFF1ED760),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print("Error picking cover image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi chọn ảnh: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _getPlaylistDuration(int count) {
    if (count == 0) return "0 phút";
    final minutes = (count * 3.5).round();
    return "$minutes phút";
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
                  player.playSong(song, queue: player.getPlaylistSongs(_currentPlaylistName));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text("Xóa khỏi danh sách phát này", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  player.removeSongFromPlaylist(_currentPlaylistName, song.title);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã xóa \"${song.title}\" khỏi danh sách phát"),
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
                final playlistSongs = player.getPlaylistSongs(_currentPlaylistName);
                
                // Filter songs inside playlist based on search text input
                final filteredSongs = playlistSongs.where((song) {
                  if (_playlistSearchQuery.isEmpty) return true;
                  final query = removeDiacritics(_playlistSearchQuery.toLowerCase());
                  final titleMatch = removeDiacritics(song.title.toLowerCase()).contains(query);
                  final artistMatch = removeDiacritics(song.artist.toLowerCase()).contains(query);
                  return titleMatch || artistMatch;
                }).toList();

                // Sort songs based on sort option selection
                if (_sortOption == "title") {
                  filteredSongs.sort((a, b) => removeDiacritics(a.title).toLowerCase().compareTo(removeDiacritics(b.title).toLowerCase()));
                } else if (_sortOption == "artist") {
                  filteredSongs.sort((a, b) => removeDiacritics(a.artist).toLowerCase().compareTo(removeDiacritics(b.artist).toLowerCase()));
                }

                // Suggestions: songs not in the playlist
                final suggestedSongs = player.playlist
                    .where((s) => !player.isSongInPlaylist(_currentPlaylistName, s.title))
                    .toList();

                final customCover = player.getPlaylistCover(_currentPlaylistName);

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Back button + Top Search Input Bar
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, top: 4),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          // Search Box
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Tìm trong danh sách phát",
                                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                                  prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                                  border: InputBorder.none,
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _playlistSearchQuery = "";
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _playlistSearchQuery = val.trim();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Header: Playlist cover + Info details
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover art
                            GestureDetector(
                              onTap: () => _pickCoverImage(player),
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF282828),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        if (customCover != null && customCover.isNotEmpty) {
                                          if (customCover.startsWith('http://') || customCover.startsWith('https://')) {
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: Image.network(
                                                customCover,
                                                width: 130,
                                                height: 130,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(
                                                  Icons.music_note,
                                                  color: Colors.white24,
                                                  size: 48,
                                                ),
                                              ),
                                            );
                                          } else {
                                            final file = File(customCover);
                                            if (file.existsSync()) {
                                              return ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.file(
                                                  file,
                                                  width: 130,
                                                  height: 130,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => const Icon(
                                                    Icons.music_note,
                                                    color: Colors.white24,
                                                    size: 48,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                        if (playlistSongs.isNotEmpty) {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: Image.network(
                                              playlistSongs.first.albumArt,
                                              width: 130,
                                              height: 130,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.music_note,
                                                color: Colors.white24,
                                                size: 48,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Icon(
                                          Icons.music_note,
                                          color: Colors.white24,
                                          size: 48,
                                        );
                                      },
                                    ),
                                    Positioned(
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.edit, color: Colors.white70, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Details text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentPlaylistName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  // Owner Avatar & Name
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: const Color(0xFFE84E36),
                                        backgroundImage: (player.userImagePath != null && player.userImagePath != 'null')
                                            ? (player.userImagePath!.startsWith('http')
                                                ? NetworkImage(player.userImagePath!)
                                                : FileImage(File(player.userImagePath!)) as ImageProvider)
                                            : null,
                                        child: (player.userImagePath == null || player.userImagePath == 'null')
                                            ? Text(
                                                player.userName.isNotEmpty
                                                    ? player.userName[0].toUpperCase()
                                                    : 'D',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        player.userName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Track count and duration estimate
                                  Text(
                                    "${playlistSongs.length} bài hát • ${_getPlaylistDuration(playlistSongs.length)}",
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions Row: Download, Share, Options, Shuffle, Play
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                playlistSongs.isNotEmpty && playlistSongs.every((s) => player.isSongDownloaded(s.title))
                                    ? Icons.arrow_circle_down
                                    : Icons.arrow_circle_down_outlined,
                                color: playlistSongs.isNotEmpty && playlistSongs.every((s) => player.isSongDownloaded(s.title))
                                    ? const Color(0xFF1ED760)
                                    : Colors.white60,
                                size: 24,
                              ),
                              onPressed: () async {
                                if (playlistSongs.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Danh sách phát không có bài hát nào để tải xuống"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                final allDownloaded = playlistSongs.every((s) => player.isSongDownloaded(s.title));
                                final nextState = !allDownloaded;
                                for (final song in playlistSongs) {
                                  if (player.isSongDownloaded(song.title) != nextState) {
                                    await player.toggleDownloadSong(song.title);
                                  }
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(nextState ? "Đã tải xuống tất cả bài hát!" : "Đã xóa nội dung tải xuống!"),
                                      backgroundColor: const Color(0xFF1ED760),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.share_outlined, color: Colors.white60, size: 22),
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: "https://open.spotify.com/playlist/${_currentPlaylistName.replaceAll(' ', '_')}"));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Đã sao chép liên kết chia sẻ vào khay nhớ tạm!"),
                                      backgroundColor: Color(0xFF1ED760),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.more_horiz, color: Colors.white60, size: 24),
                              onPressed: () => _showPlaylistMoreOptions(context, player),
                            ),
                            const Spacer(),
                            // Shuffle toggle button
                            IconButton(
                              icon: Icon(
                                Icons.shuffle,
                                color: player.isShuffled ? const Color(0xFF1ED760) : Colors.white54,
                                size: 22,
                              ),
                              onPressed: () => player.toggleShuffle(),
                            ),
                            const SizedBox(width: 16),
                            // Green Circle Play/Pause button
                            Builder(
                              builder: (context) {
                                final isThisPlaylistPlaying = player.isPlaying &&
                                    playlistSongs.isNotEmpty &&
                                    playlistSongs.any((s) => s.title == player.currentSong.title);

                                return GestureDetector(
                                  onTap: () {
                                    if (playlistSongs.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Danh sách phát rỗng!"),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }

                                    if (isThisPlaylistPlaying) {
                                      player.pause();
                                    } else {
                                      final index = playlistSongs.indexWhere((s) => s.title == player.currentSong.title);
                                      if (index != -1) {
                                        player.play();
                                      } else {
                                        if (player.isShuffled) {
                                          final randomSongs = List<Song>.from(playlistSongs)..shuffle();
                                          player.playSong(randomSongs.first, queue: randomSongs);
                                        } else {
                                          player.playSong(playlistSongs.first, queue: playlistSongs);
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
                                      isThisPlaylistPlaying ? Icons.pause : Icons.play_arrow,
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

                    // Chips Row: Add, Edit, Sort, Edit Pencil Icon
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            // Add Songs Chip
                            GestureDetector(
                              onTap: () {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text("Thêm", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Edit Playlist Chip
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEditMode = !_isEditMode;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isEditMode ? const Color(0xFF1ED760) : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isEditMode ? Icons.check : Icons.remove,
                                      color: _isEditMode ? Colors.black : Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isEditMode ? "Xong" : "Chỉnh sửa",
                                      style: TextStyle(
                                        color: _isEditMode ? Colors.black : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Sort Chip
                            GestureDetector(
                              onTap: () => _showSortOptions(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _sortOption != "default" ? const Color(0xFF1ED760) : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.unfold_more,
                                      color: _sortOption != "default" ? Colors.black : Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _sortOption == "default"
                                          ? "Sắp xếp"
                                          : (_sortOption == "title" ? "Tiêu đề" : "Nghệ sĩ"),
                                      style: TextStyle(
                                        color: _sortOption != "default" ? Colors.black : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Edit Icon button
                            GestureDetector(
                              onTap: () => _showRenameDialog(context, player),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2A2A2A),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.edit, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Playlist Songs list
                    if (filteredSongs.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final song = filteredSongs[index];
                              final isPlaying = player.isPlaying && player.currentSong.title == song.title;

                              return InkWell(
                                onTap: () => player.playSong(song, queue: player.getPlaylistSongs(_currentPlaylistName)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    children: [
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
                                      // Title + artist
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
                                      // Toggle between Edit Mode (delete) or Options Mode (three dots)
                                      _isEditMode
                                          ? IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                              onPressed: () {
                                                player.removeSongFromPlaylist(_currentPlaylistName, song.title);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Đã xóa \"${song.title}\" khỏi danh sách phát"),
                                                    backgroundColor: Colors.redAccent,
                                                    duration: const Duration(seconds: 1),
                                                  ),
                                                );
                                              },
                                            )
                                          : IconButton(
                                              icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                                              onPressed: () => _showSongOptions(context, song, player),
                                            ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: filteredSongs.length,
                          ),
                        ),
                      ),
                    ] else if (_playlistSearchQuery.isNotEmpty) ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              "Không tìm thấy bài hát nào.",
                              style: TextStyle(color: Colors.white30, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                          child: Column(
                            children: [
                              Icon(Icons.music_note, color: Colors.white24, size: 48),
                              SizedBox(height: 12),
                              Text(
                                "Chưa có bài hát nào trong danh sách.",
                                style: TextStyle(color: Colors.white30, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // "Thêm vào danh sách phát này" (Suggest button)
                    if (playlistSongs.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut,
                              );
                            },
                            icon: const Icon(Icons.add, color: Colors.white, size: 20),
                            label: const Text(
                              "Thêm vào danh sách phát này",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white38),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ),
                      ),

                    // "Bài hát Gợi ý" Header & Subtitle
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bài hát Gợi ý",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Dựa trên bài hát trong danh sách phát này",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Suggested songs list
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = suggestedSongs[index];
                          return _buildSuggestedSongItem(context, song, player);
                        },
                        childCount: suggestedSongs.length,
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

  Widget _buildSuggestedSongItem(BuildContext context, Song song, PlayerService player) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: SizedBox(
        width: 48,
        height: 48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            song.albumArt,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF282828),
              child: const Icon(Icons.music_note, color: Colors.white24, size: 24),
            ),
          ),
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline, color: Colors.white54, size: 22),
        onPressed: () {
          player.addSongToPlaylist(_currentPlaylistName, song.title);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Đã thêm \"${song.title}\" vào danh sách phát"),
              backgroundColor: const Color(0xFF1ED760),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
      onTap: () {
        player.playSong(song, queue: player.getPlaylistSongs(_currentPlaylistName));
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, PlayerService player) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Xóa danh sách phát?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text("Bạn có chắc chắn muốn xóa danh sách phát \"$_currentPlaylistName\" không? Hành động này không thể hoàn tác.", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () async {
                await player.deleteCustomPlaylist(_currentPlaylistName);
                if (mounted) {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Pop screen back to Library
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã xóa danh sách phát \"$_currentPlaylistName\""),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text("Xóa", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllConfirmDialog(BuildContext context, PlayerService player) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Xóa tất cả bài hát?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text("Bạn có chắc chắn muốn xóa tất cả bài hát khỏi \"$_currentPlaylistName\" không?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () async {
                final playlistSongs = player.getPlaylistSongs(_currentPlaylistName);
                for (final song in playlistSongs) {
                  await player.removeSongFromPlaylist(_currentPlaylistName, song.title);
                }
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đã xóa tất cả bài hát khỏi danh sách phát"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text("Xóa tất cả", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showPlaylistMoreOptions(BuildContext context, PlayerService player) {
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
                  _currentPlaylistName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white),
                title: const Text("Đổi tên danh sách phát", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showRenameDialog(context, player);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: Colors.white),
                title: const Text("Thay đổi ảnh bìa", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickCoverImage(player);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.white),
                title: const Text("Chia sẻ danh sách phát", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Clipboard.setData(ClipboardData(text: "https://open.spotify.com/playlist/${_currentPlaylistName.replaceAll(' ', '_')}"));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đã sao chép liên kết chia sẻ vào khay nhớ tạm!"),
                        backgroundColor: Color(0xFF1ED760),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
                title: const Text("Xóa tất cả bài hát", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showClearAllConfirmDialog(context, player);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text("Xóa danh sách phát", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmDialog(context, player);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortOptions(BuildContext context) {
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
                  "Sắp xếp theo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              _buildSortOptionTile(ctx, "Mặc định", "default"),
              _buildSortOptionTile(ctx, "Tiêu đề (A-Z)", "title"),
              _buildSortOptionTile(ctx, "Nghệ sĩ", "artist"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOptionTile(BuildContext ctx, String label, String value) {
    final isSelected = _sortOption == value;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF1ED760) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF1ED760)) : null,
      onTap: () {
        setState(() {
          _sortOption = value;
        });
        Navigator.pop(ctx);
      },
    );
  }

  void _showRenameDialog(BuildContext context, PlayerService player) {
    _nameController.text = _currentPlaylistName;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "Đổi tên danh sách phát",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _nameController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Tên mới",
              hintStyle: TextStyle(color: Colors.white30),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1ED760),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty && newName != _currentPlaylistName) {
                  await player.renameCustomPlaylist(_currentPlaylistName, newName);
                  if (mounted) {
                    setState(() {
                      _currentPlaylistName = newName;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đã đổi tên danh sách phát thành: $newName"),
                        backgroundColor: const Color(0xFF1ED760),
                      ),
                    );
                  }
                } else {
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Lưu", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
