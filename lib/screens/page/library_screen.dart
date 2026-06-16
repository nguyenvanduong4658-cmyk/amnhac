import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/player_service.dart';
import '../../models/song.dart';
import '../../models/artist.dart';
import 'playlist_detail_screen.dart';
import 'artist_detail_screen.dart';
import 'liked_songs_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedChip = "Tất cả";
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    Scaffold.of(context).openDrawer();
  }

  void _createNewPlaylistPrompt() {
    final TextEditingController playlistController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "Tạo danh sách phát",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: playlistController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Tên danh sách phát",
              hintStyle: TextStyle(color: Colors.white30),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1ED760),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final name = playlistController.text.trim();
                if (name.isNotEmpty) {
                  await PlayerService().addCustomPlaylist(name);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đã tạo danh sách phát: $name"),
                        backgroundColor: const Color(0xFF1ED760),
                      ),
                    );
                  }
                }
              },
              child: const Text("Tạo", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
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
        child: AnimatedBuilder(
          animation: player,
          builder: (context, child) {
            final initialLetter = player.userName.isNotEmpty 
                ? player.userName[0].toUpperCase() 
                : 'D';

            // Filter items based on selected chip
            final showPlaylists = _selectedChip == "Tất cả" || _selectedChip == "Danh sách phát";
            final showArtists = _selectedChip == "Tất cả" || _selectedChip == "Nghệ sĩ";

            final showLikedSongsTile = showPlaylists &&
                (_searchQuery.isEmpty || "bài hát đã thích".contains(_searchQuery));

            final filteredPlaylists = player.customPlaylists
                .where((name) => _searchQuery.isEmpty || name.toLowerCase().contains(_searchQuery))
                .toList();

            final filteredArtists = player.followedArtists
                .where((artist) => _searchQuery.isEmpty || artist.name.toLowerCase().contains(_searchQuery))
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      if (_isSearching) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchQuery = "";
                              _searchController.clear();
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: "Tìm trong thư viện...",
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
                              border: InputBorder.none,
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.white54),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = "";
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim().toLowerCase();
                              });
                            },
                          ),
                        ),
                      ] else ...[
                        // Avatar Link
                        GestureDetector(
                          onTap: _openDrawer,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFE84E36),
                            backgroundImage: (player.userImagePath != null && player.userImagePath != 'null')
                                ? (player.userImagePath!.startsWith('http')
                                    ? NetworkImage(player.userImagePath!)
                                    : FileImage(File(player.userImagePath!)) as ImageProvider)
                                : null,
                            child: player.userImagePath == null
                                ? Text(
                                    initialLetter,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Thư viện",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isSearching = true;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () => _showAddMenu(context),
                        ),
                      ],
                    ],
                  ),
                ),

                // Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      _buildFilterChip("Tất cả"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Danh sách phát"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Nghệ sĩ"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Dynamic Library Items List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // 1. Liked Songs (Always Playlist, dynamic count)
                      if (showLikedSongsTile)
                        _buildLikedSongsTile(context, player.likedSongTitles.length),

                      // 2. Custom Playlists
                      if (showPlaylists)
                        ...filteredPlaylists.map(
                          (playlistName) => _buildCustomPlaylistTile(context, playlistName),
                        ),

                      // 3. Dynamic Followed Artists
                      if (showArtists) ...[
                        ...filteredArtists.map(
                          (artist) => _buildArtistTile(context, artist.name, artist.imageUrl),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          _buildAddArtistTile(context),
                          _buildAddMusicTile(context),
                        ],
                      ],
                      const SizedBox(height: 100), // bottom spacer
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedChip == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChip = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1ED760) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLikedSongsTile(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF450E4E), Color(0xFFC43A30)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.favorite, color: Colors.white, size: 24),
        ),
        title: const Text(
          "Bài hát đã thích",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.push_pin, color: Color(0xFF1ED760), size: 14),
            const SizedBox(width: 4),
            Text(
              "Danh sách phát • $count bài hát",
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LikedSongsScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomPlaylistTile(BuildContext context, String name) {
    final player = PlayerService();
    final customCover = player.getPlaylistCover(name);
    final playlistSongs = player.getPlaylistSongs(name);

    Widget leadingWidget;
    if (customCover != null && customCover.isNotEmpty) {
      if (customCover.startsWith('http://') || customCover.startsWith('https://')) {
        leadingWidget = Image.network(
          customCover,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white60, size: 24),
        );
      } else {
        final file = File(customCover);
        if (file.existsSync()) {
          leadingWidget = Image.file(
            file,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white60, size: 24),
          );
        } else {
          leadingWidget = const Icon(Icons.music_note, color: Colors.white60, size: 24);
        }
      }
    } else if (playlistSongs.isNotEmpty) {
      leadingWidget = Image.network(
        playlistSongs.first.albumArt,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white60, size: 24),
      );
    } else {
      leadingWidget = const Icon(Icons.music_note, color: Colors.white60, size: 24);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAlias,
          child: leadingWidget,
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          "Danh sách phát • Bạn tạo",
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onPressed: () => _showPlaylistOptions(context, name),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistDetailScreen(playlistName: name),
            ),
          );
        },
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text("Tạo danh sách phát mới", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _createNewPlaylistPrompt();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.white),
                title: const Text("Thêm nghệ sĩ mới", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _createNewArtistPrompt();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _createNewArtistPrompt() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    String? selectedLocalImagePath;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                "Thêm nghệ sĩ mới",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Tên nghệ sĩ",
                        hintStyle: TextStyle(color: Colors.white30),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Link ảnh nghệ sĩ (URL)",
                        hintStyle: TextStyle(color: Colors.white30),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "HOẶC",
                      style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setDialogState(() {
                            selectedLocalImagePath = picked.path;
                            imageController.text = ""; // Clear URL if chosen local
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: Text(
                        selectedLocalImagePath != null ? "Đã chọn ảnh máy" : "Chọn ảnh từ máy",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (selectedLocalImagePath != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        selectedLocalImagePath!.split(Platform.pathSeparator).last,
                        style: const TextStyle(color: Color(0xFF1ED760), fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1ED760),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final url = imageController.text.trim();
                    final finalImg = selectedLocalImagePath ?? url;

                    if (name.isNotEmpty && finalImg.isNotEmpty) {
                      await PlayerService().addFollowedArtist(name, finalImg);
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đã thêm nghệ sĩ: $name"),
                            backgroundColor: const Color(0xFF1ED760),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Thêm", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPlaylistOptions(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text("Đổi tên danh sách phát", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showRenamePlaylistDialog(name);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.white),
                title: const Text("Thay đổi ảnh bìa", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    await PlayerService().setPlaylistCover(name, picked.path);
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã cập nhật ảnh bìa danh sách phát!"),
                          backgroundColor: Color(0xFF1ED760),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text("Xóa danh sách phát", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeletePlaylistDialog(name);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenamePlaylistDialog(String oldName) {
    final TextEditingController renameController = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "Đổi tên danh sách phát",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: renameController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Tên mới",
              hintStyle: TextStyle(color: Colors.white30),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1ED760),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final newName = renameController.text.trim();
                if (newName.isNotEmpty && newName != oldName) {
                  await PlayerService().renameCustomPlaylist(oldName, newName);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đã đổi tên danh sách phát thành: $newName"),
                        backgroundColor: const Color(0xFF1ED760),
                      ),
                    );
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text("Lưu", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeletePlaylistDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Xóa danh sách phát?"),
        content: Text("Bạn có chắc chắn muốn xóa danh sách phát '$name'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              await PlayerService().deleteCustomPlaylist(name);
              if (this.context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text("Đã xóa danh sách phát: $name"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showArtistOptions(BuildContext context, String name, String imageUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text("Sửa thông tin nghệ sĩ", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditArtistDialog(name, imageUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.redAccent),
                title: const Text("Xóa nghệ sĩ", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteArtistDialog(name);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditArtistDialog(String oldName, String oldImageUrl) {
    final TextEditingController nameController = TextEditingController(text: oldName);
    final TextEditingController imageController = TextEditingController(text: oldImageUrl.startsWith('http') ? oldImageUrl : "");
    String? selectedLocalImagePath = oldImageUrl.startsWith('http') ? null : oldImageUrl;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                "Sửa thông tin nghệ sĩ",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Tên nghệ sĩ",
                        hintStyle: TextStyle(color: Colors.white30),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Link ảnh nghệ sĩ (URL)",
                        hintStyle: TextStyle(color: Colors.white30),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "HOẶC",
                      style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setDialogState(() {
                            selectedLocalImagePath = picked.path;
                            imageController.text = ""; // Clear URL if chosen local
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: Text(
                        selectedLocalImagePath != null ? "Đã chọn ảnh máy" : "Chọn ảnh từ máy",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (selectedLocalImagePath != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        selectedLocalImagePath!.split(Platform.pathSeparator).last,
                        style: const TextStyle(color: Color(0xFF1ED760), fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1ED760),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    final url = imageController.text.trim();
                    final finalImg = selectedLocalImagePath ?? url;

                    if (newName.isNotEmpty && finalImg.isNotEmpty) {
                      await PlayerService().updateFollowedArtist(oldName, newName, finalImg);
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đã sửa thông tin nghệ sĩ: $newName"),
                            backgroundColor: const Color(0xFF1ED760),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Lưu", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteArtistDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Xóa nghệ sĩ?"),
        content: Text("Bạn có muốn ngừng theo dõi/xóa nghệ sĩ '$name' khỏi thư viện?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              await PlayerService().removeFollowedArtist(name);
              if (this.context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text("Đã xóa nghệ sĩ: $name"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistTile(BuildContext context, String name, String imageUrl) {
    ImageProvider imageProvider;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      imageProvider = NetworkImage(imageUrl);
    } else {
      imageProvider = FileImage(File(imageUrl));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: imageProvider,
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          "Nghệ sĩ",
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onPressed: () => _showArtistOptions(context, name, imageUrl),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtistDetailScreen(artistName: name),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddArtistTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF282828),
          child: const Icon(Icons.add, color: Colors.white60, size: 28),
        ),
        title: const Text(
          "Thêm nghệ sĩ",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: _createNewArtistPrompt,
      ),
    );
  }

  Widget _buildAddMusicTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.move_to_inbox_outlined, color: Colors.white60, size: 28),
        ),
        title: const Text(
          "Thêm nhạc",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: _createNewMusicPrompt,
      ),
    );
  }

  void _createNewMusicPrompt() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController artistController = TextEditingController();
    final TextEditingController audioUrlController = TextEditingController();
    final TextEditingController albumArtUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "Thêm bài hát mới",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Tên bài hát",
                    hintStyle: TextStyle(color: Colors.white30),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: artistController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Tên nghệ sĩ",
                    hintStyle: TextStyle(color: Colors.white30),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: audioUrlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Link file âm thanh (MP3 URL)",
                    hintStyle: TextStyle(color: Colors.white30),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: albumArtUrlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Link ảnh bìa album (URL)",
                    hintStyle: TextStyle(color: Colors.white30),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1ED760),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                final artist = artistController.text.trim();
                final audioUrl = audioUrlController.text.trim();
                final albumArt = albumArtUrlController.text.trim();

                if (title.isNotEmpty && artist.isNotEmpty && audioUrl.isNotEmpty) {
                  final newSong = Song(
                    title: title,
                    artist: artist,
                    audioUrl: audioUrl,
                    albumArt: albumArt.isNotEmpty ? albumArt : "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80",
                    bannerText: "",
                    subtitle: artist,
                    themeColor: const Color(0xFF1E293B),
                    lyrics: [],
                  );
                  await PlayerService().addNewSong(newSong);
                  if (mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đã thêm bài hát: $title"),
                        backgroundColor: const Color(0xFF1ED760),
                      ),
                    );
                  }
                }
              },
              child: const Text("Thêm", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

// Playlist details sub-page
class PlaylistDetailPage extends StatelessWidget {
  final String playlistName;
  final bool isArtist;

  const PlaylistDetailPage({
    super.key,
    required this.playlistName,
    this.isArtist = false,
  });

  @override
  Widget build(BuildContext context) {
    final player = PlayerService();
    List<Song> songsToShow = [];

    if (playlistName == "Bài hát đã thích") {
      songsToShow = player.playlist.where((s) => player.isSongLiked(s)).toList();
    } else if (isArtist) {
      songsToShow = player.playlist.where((s) => s.artist.contains(playlistName) || s.subtitle.contains(playlistName)).toList();
    } else {
      // Custom playlists will show all database songs for demo listening purposes, but customizable
      songsToShow = player.playlist;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(playlistName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Play All Header button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${songsToShow.length} bài hát",
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  if (songsToShow.isNotEmpty)
                    FloatingActionButton(
                      backgroundColor: const Color(0xFF1ED760),
                      mini: false,
                      onPressed: () {
                        player.playSong(songsToShow.first);
                      },
                      child: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Songs List
              Expanded(
                child: songsToShow.isEmpty
                    ? const Center(
                        child: Text(
                          "Danh sách phát này trống.",
                          style: TextStyle(color: Colors.white30, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: songsToShow.length,
                        itemBuilder: (context, index) {
                          final song = songsToShow[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                song.albumArt,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFF242424),
                                  width: 50,
                                  height: 50,
                                  child: const Icon(Icons.music_note, color: Colors.white30, size: 24),
                                ),
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text(
                              song.artist,
                              style: const TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                            onTap: () {
                              player.playSong(song);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
