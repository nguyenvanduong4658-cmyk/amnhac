import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/player_service.dart';
import '../auth/welcome_screen.dart';

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
      appBar: AppBar(
        title: const Text(
          'Trang cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Reset fields on cancel
                  _nameController.text = player.userName;
                  _emailController.text = player.userEmail;
                  _phoneController.text = player.userPhone;
                  _imagePath = player.userImagePath;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.grey.shade900,
                      backgroundImage: (_imagePath != null && _imagePath != 'null')
                          ? (_imagePath!.startsWith('http')
                              ? NetworkImage(_imagePath!)
                              : FileImage(File(_imagePath!)) as ImageProvider)
                          : null,
                      child: _imagePath == null
                          ? Text(
                              initialLetter,
                              style: const TextStyle(
                                fontSize: 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1ED760),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                player.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                player.userEmail,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Profile info cards / Edit Form
            if (_isEditing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tên hiển thị",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: "Nhập tên"),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    "Email",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: "Nhập email"),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    "Số điện thoại",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: "Nhập số điện thoại"),
                  ),
                  const SizedBox(height: 24),
                  
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
                      ),
                      onPressed: _saveChanges,
                      child: const Text(
                        'Lưu thay đổi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildProfileFieldTile(Icons.person, "Tên người dùng", player.userName),
                  const SizedBox(height: 12),
                  _buildProfileFieldTile(Icons.email, "Email", player.userEmail),
                  const SizedBox(height: 12),
                  _buildProfileFieldTile(Icons.phone, "Số điện thoại", player.userPhone),
                  const SizedBox(height: 32),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        foregroundColor: Colors.redAccent,
                      ),
                      onPressed: _logout,
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileFieldTile(IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1ED760), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
