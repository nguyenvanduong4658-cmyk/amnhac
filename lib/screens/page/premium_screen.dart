import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Premium banner card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D5E4D), Color(0xFF1E7A68)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "PREMIUM",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Miễn phí Premium trong 1 tháng",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sau đó chỉ với 59.000 ₫/tháng. Hủy bất cứ lúc nào.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "DÙNG THỬ 1 THÁNG MIỄN PHÍ",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Áp dụng điều khoản. Ưu đãi chỉ dành cho người dùng chưa từng dùng thử Premium.",
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Tại sao nên dùng Premium?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureTile(
                icon: Icons.block,
                title: "Tắt quảng cáo",
                subtitle: "Thưởng thức âm nhạc liên tục không bị gián đoạn.",
              ),
              const SizedBox(height: 16),
              _buildFeatureTile(
                icon: Icons.download,
                title: "Tải nhạc về thiết bị",
                subtitle: "Nghe ngoại tuyến ở bất cứ nơi đâu mà không cần mạng.",
              ),
              const SizedBox(height: 16),
              _buildFeatureTile(
                icon: Icons.shuffle,
                title: "Phát nhạc theo thứ tự bất kỳ",
                subtitle: "Tự do chọn bài hát bạn muốn nghe mọi lúc.",
              ),
              const SizedBox(height: 16),
              _buildFeatureTile(
                icon: Icons.high_quality,
                title: "Chất lượng âm thanh cao hơn",
                subtitle: "Cảm nhận âm nhạc sống động và chi tiết vượt trội.",
              ),
              const SizedBox(height: 80), // spacer for mini player
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1ED760), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
