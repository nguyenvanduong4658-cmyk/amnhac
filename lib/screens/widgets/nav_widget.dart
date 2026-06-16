import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: (currentIndex >= 0 && currentIndex < 5) ? currentIndex : 0,
        type: BottomNavigationBarType.fixed,
        onTap: onTap,
        backgroundColor: Colors.black,
        selectedItemColor: (currentIndex >= 0 && currentIndex < 5) ? Colors.white : Colors.grey.shade600,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 11,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 0 ? Icons.home : Icons.home_outlined,
              size: 24,
            ),
            label: "Trang chủ",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 24),
            label: "Tìm kiếm",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined, size: 24),
            label: "Thư viện",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.stars_outlined, size: 24), // Star representation for Premium
            label: "Premium",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined, size: 24),
            label: "Tạo",
          ),
        ],
      ),
    );
  }
}