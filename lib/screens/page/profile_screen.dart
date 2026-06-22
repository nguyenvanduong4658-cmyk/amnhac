import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/player_service.dart';
import '../auth/welcome_screen.dart';
import '../auth/change_password_screen.dart';
import 'playlist_detail_screen.dart';
import '../mainpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _imagePath;
  late final PlayerService _playerService;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _nameController = TextEditingController(text: _playerService.userName);
    _emailController = TextEditingController(text: _playerService.userEmail);
    _phoneController = TextEditingController(text: _playerService.userPhone);
    _imagePath = _playerService.userImagePath;
    _playerService.addListener(_onPlayerServiceChanged);
  }

  void _onPlayerServiceChanged() {
    if (!_isEditing && mounted) {
      setState(() {
        _nameController.text = _playerService.userName;
        _emailController.text = _playerService.userEmail;
        _phoneController.text = _playerService.userPhone;
        _imagePath = _playerService.userImagePath;
      });
    }
  }

  @override
  void dispose() {
    _playerService.removeListener(_onPlayerServiceChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
      // Save changes immediately for the picture
      await PlayerService().updateProfile(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        picked.path,
      );
    }
  }

  void _saveChanges() async {
    await PlayerService().updateProfile(
      _nameController.text,
      _emailController.text,
      _phoneController.text,
      _imagePath,
    );

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công!'),
          backgroundColor: Color(0xFF1ED760),
        ),
      );
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_logged_in', false);
    await prefs.remove('current_uid');
    
    // Reset PlayerService state if necessary
    PlayerService().pause();
    await PlayerService().loadProfile();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đăng xuất!'),
          backgroundColor: Colors.white24,
        ),
      );
      
      // Navigate to welcome page and clear history
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false,
      );
    }
  }

   @override
  Widget build(BuildContext context) {
    final player = PlayerService();
    final initialLetter = _nameController.text.isNotEmpty 
        ? _nameController.text[0].toUpperCase() 
        : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD84A24), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back Button Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header Row
                      AnimatedBuilder(
                        animation: player,
                        builder: (context, child) {
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 54,
                                      backgroundColor: const Color(0xFFE84E36),
                                      backgroundImage: (_imagePath != null && _imagePath != 'null')
                                          ? (_imagePath!.startsWith('http')
                                              ? NetworkImage(_imagePath!)
                                              : FileImage(File(_imagePath!)) as ImageProvider)
                                          : null,
                                      child: _imagePath == null
                                          ? Text(
                                              initialLetter,
                                              style: const TextStyle(
                                                fontSize: 42,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                    if (_isEditing)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF1ED760),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.userName.isNotEmpty ? player.userName : "Người dùng",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      "0 người theo dõi • Đang theo dõi 4",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons Row
                      Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                                if (!_isEditing) {
                                  _nameController.text = player.userName;
                                  _emailController.text = player.userEmail;
                                  _phoneController.text = player.userPhone;
                                  _imagePath = player.userImagePath;
                                }
                              });
                            },
                            child: Text(
                              _isEditing ? "Hủy" : "Chỉnh sửa",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white54, size: 22),
                            onPressed: () => _showSettingsSheet(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white54, size: 22),
                            onPressed: () => _showMoreOptionsSheet(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Body Content
                      if (_isEditing) ...[
                        _buildEditForm(),
                      ] else ...[
                        _buildPlaylistsSection(player),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CHỈNH SỬA THÔNG TIN",
          style: TextStyle(color: Color(0xFF1ED760), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 20),
        _buildTextField("Tên hiển thị", _nameController, Icons.person),
        const SizedBox(height: 16),
        _buildTextField("Email", _emailController, Icons.email),
        const SizedBox(height: 16),
        _buildTextField("Số điện thoại", _phoneController, Icons.phone),
        const SizedBox(height: 32),
        
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1ED760),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            onPressed: _saveChanges,
            child: const Text(
              'Lưu thay đổi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFF242424),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1ED760), width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistsSection(PlayerService player) {
    final playlists = player.customPlaylists.isNotEmpty
        ? player.customPlaylists
        : ["T", "Học thêm", "nhạc"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Danh sách phát",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _createNewPlaylistPrompt,
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    "Quản lý",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final name = playlists[index];
            final playlistSongs = player.customPlaylists.contains(name)
                ? player.getPlaylistSongs(name)
                : [];
            
            final subtitleText = player.customPlaylists.contains(name)
                ? "${playlistSongs.length} bài hát • 0 lượt lưu"
                : "0 lượt lưu";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _buildPlaylistLeading(name, player),
                title: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  subtitleText,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  onPressed: () {
                    if (player.customPlaylists.contains(name)) {
                      _showPlaylistOptions(context, name);
                    } else {
                      _showMockPlaylistOptions(context, name);
                    }
                  },
                ),
                onTap: () {
                  if (player.customPlaylists.contains(name)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailScreen(playlistName: name),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đây là danh sách phát mẫu: $name"),
                        backgroundColor: const Color(0xFF1E2631),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        Center(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              MainPage.activeState?.changeTab(2);
            },
            child: const Text(
              "Xem tất cả danh sách phát",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistLeading(String name, PlayerService player) {
    if (name == "T" && player.customPlaylists.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E3D49), Color(0xFF1B262C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: const Text(
          "T",
          style: TextStyle(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }

    final customCover = player.customPlaylists.contains(name) ? player.getPlaylistCover(name) : null;
    final playlistSongs = player.customPlaylists.contains(name) ? player.getPlaylistSongs(name) : [];

    if (customCover != null && customCover.isNotEmpty) {
      if (customCover.startsWith('http://') || customCover.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(customCover, width: 56, height: 56, fit: BoxFit.cover),
        );
      } else {
        final file = File(customCover);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(file, width: 56, height: 56, fit: BoxFit.cover),
          );
        }
      }
    } else if (playlistSongs.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(playlistSongs.first.albumArt, width: 56, height: 56, fit: BoxFit.cover),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54, size: 28),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Cài đặt tài khoản",
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.white),
                title: const Text("Đổi mật khẩu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white70),
                title: const Text("Đăng xuất", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _logout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text("Xóa tài khoản", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmDeleteAccount(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Xóa tài khoản?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Hành động này là vĩnh viễn và không thể hoàn tác. Bạn sẽ mất toàn bộ danh sách phát, lượt thích và thông tin cá nhân.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _promptPasswordForDeletion(context);
            },
            child: const Text(
              "Xóa",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _promptPasswordForDeletion(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (passwordCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                "Xác thực bảo mật",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Vui lòng nhập mật khẩu hiện tại để xác nhận việc xóa tài khoản.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Mật khẩu",
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF242424),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(passwordCtx),
                  child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      final password = passwordController.text.trim();
                      if (password.isEmpty) {
                        setDialogState(() {
                          errorMessage = "Vui lòng nhập mật khẩu!";
                        });
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      final result = await PlayerService().deleteAccount(password: password);

                      if (!mounted) return;

                      if (result == null) {
                        Navigator.pop(passwordCtx);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Tài khoản của bạn đã được xóa thành công!"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomePage()),
                          (route) => false,
                        );
                      } else {
                        setDialogState(() {
                          isLoading = false;
                          errorMessage = result;
                        });
                      }
                    },
                    child: const Text(
                      "Xác nhận",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMoreOptionsSheet(BuildContext context) {
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
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text("Chia sẻ hồ sơ", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã sao chép liên kết hồ sơ!")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMockPlaylistOptions(BuildContext context, String name) {
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
                leading: const Icon(Icons.lock, color: Colors.white54),
                title: Text("Danh sách phát mẫu: $name", style: const TextStyle(color: Colors.white54)),
                subtitle: const Text("Không thể sửa đổi danh sách phát mẫu này", style: TextStyle(color: Colors.white30, fontSize: 11)),
              ),
            ],
          ),
        );
      },
    );
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
                      ScaffoldMessenger.of(context).showSnackBar(
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
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
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
}
