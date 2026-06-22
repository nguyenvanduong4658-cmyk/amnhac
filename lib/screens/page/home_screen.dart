import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/player_service.dart';
import '../../models/song.dart';
import 'recently_played_screen.dart';
import 'artist_detail_screen.dart';
import '../widgets/spinning_album_art.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = "Nhạc";

  void _openDrawer() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerService();



    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: player,
            builder: (context, child) {
              final initialLetter = player.userName.isNotEmpty 
                  ? player.userName[0].toUpperCase() 
                  : 'D';

              final songSonTung = player.playlist.firstWhere((s) => s.artist.contains("Sơn Tùng M-TP"), orElse: () => player.playlist[0]);
              final songWren = player.playlist.firstWhere((s) => s.artist.contains("Wren Evans"), orElse: () => player.playlist[0]);
              final songTlinh = player.playlist.firstWhere((s) => s.artist.contains("tlinh"), orElse: () => player.playlist[0]);
              final songHieuThuHai = player.playlist.firstWhere((s) => s.artist.contains("HIEUTHUHAI"), orElse: () => player.playlist.length > 1 ? player.playlist[1] : player.playlist[0]);
              final songMck = player.playlist.firstWhere((s) => s.artist.contains("MCK"), orElse: () => player.playlist[0]);
              final songGreyD = player.playlist.firstWhere((s) => s.artist.contains("GREY D"), orElse: () => player.playlist[0]);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Top Profile and Filters Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Clickable Profile Avatar
                        GestureDetector(
                          onTap: _openDrawer,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFE84E36), // Orange-Red color from screenshot
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
                        const SizedBox(width: 8),
                        // Scrollable Category Pills
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildPill("Tất cả"),
                                _buildPill("Nhạc"),
                                _buildPill("Đang theo dõi"),
                                _buildPill("Podcasts"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Recently Played Clock Icon
                        IconButton(
                          icon: const Icon(Icons.history, color: Colors.white, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RecentlyPlayedPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dynamic display based on selection
                  if (_selectedCategory == "Tất cả") ...[
                    // Section 1: Tuyển tập hàng đầu của bạn
                    _buildSectionHeader("Tuyển tập hàng đầu của bạn"),
                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16.0),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildSpotifyPlaylistCard(
                            context: context,
                            song: songSonTung,
                            bannerText: "Tuyển tập của\nSơn Tùng M-TP",
                            bannerColor: const Color(0xFF4A2A5A),
                            textColor: Colors.white,
                            subtitle: "HIEUTHUHAI, Wren Evans và MCK",
                            spotifyIconColor: Colors.white,
                            imageUrl: songSonTung.albumArt,
                          ),
                          _buildSpotifyPlaylistCard(
                            context: context,
                            song: songTlinh,
                            bannerText: "Tuyển tập của\ntlinh",
                            bannerColor: const Color(0xFF2E6B5E),
                            textColor: Colors.white,
                            subtitle: "MCK, GREY D và Wren Evans",
                            spotifyIconColor: Colors.white,
                            imageUrl: songTlinh.albumArt,
                          ),
                          _buildSpotifyPlaylistCard(
                            context: context,
                            song: songWren,
                            bannerText: "Tuyển tập của\nWren Evans",
                            bannerColor: const Color(0xFF5A1E29),
                            textColor: Colors.white,
                            subtitle: "tlinh, GREY D và MCK",
                            spotifyIconColor: Colors.white,
                            imageUrl: songWren.albumArt,
                          ),
                          _buildSpotifyPlaylistCard(
                            context: context,
                            song: songMck,
                            bannerText: "Tuyển tập của\nMCK",
                            bannerColor: const Color(0xFF425664),
                            textColor: Colors.white,
                            subtitle: "tlinh, GREY D và Wren Evans",
                            spotifyIconColor: Colors.white,
                            imageUrl: songMck.albumArt,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Để bạn bắt đầu
                    _buildSectionHeader("Để bạn bắt đầu"),
                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16.0),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildSpotifyPlaylistCard(
                            context: context,
                            song: songHieuThuHai,
                            bannerText: "Tuyển tập của\nHIEUTHUHAI",
                            bannerColor: const Color(0xFF2C3E50),
                            textColor: Colors.white,
                            subtitle: "Sơn Tùng M-TP, Wren Evans và tlinh",
                            spotifyIconColor: Colors.white,
                            imageUrl: songHieuThuHai.albumArt,
                          ),
                          _buildSpotifyPlaylistCard(
                            context: context,
                            song: songGreyD,
                            bannerText: "Tuyển tập của\nGREY D",
                            bannerColor: const Color(0xFF8F6B58),
                            textColor: Colors.white,
                            subtitle: "tlinh, HIEUTHUHAI và Wren Evans",
                            spotifyIconColor: Colors.white,
                            imageUrl: songGreyD.albumArt,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 3: Nội dung bạn hay nghe gần đây
                    if (player.recentlyPlayedList.isNotEmpty) ...[
                      _buildSectionHeader("Nội dung bạn hay nghe gần đây"),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: player.recentlyPlayedList.length,
                        itemBuilder: (context, index) {
                          final item = player.recentlyPlayedList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFF242424),
                                    width: 48,
                                    height: 48,
                                    child: const Icon(Icons.music_note, color: Colors.white24, size: 24),
                                  ),
                                ),
                              ),
                              title: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                item.type == 'artist'
                                    ? "Nghệ sĩ"
                                    : (item.type == 'playlist' ? "Danh sách phát" : "Bài hát"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: const Icon(Icons.more_vert, color: Colors.white54),
                              onTap: () {
                                if (item.type == 'song') {
                                  final songMatch = player.playlist.firstWhere(
                                    (s) => s.title.toLowerCase() == item.title.toLowerCase(),
                                    orElse: () => player.playlist.first,
                                  );
                                  player.playSong(songMatch);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Đang phát danh mục: ${item.title}"),
                                      backgroundColor: const Color(0xFF1ED760),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                  if (_selectedCategory == "Nhạc") ...[
                    _buildMusicCategoryView(context, player),
                  ],
                  if (_selectedCategory == "Podcasts") ...[
                    _buildPodcastsCategoryView(context, player),
                  ],
                  if (_selectedCategory == "Đang theo dõi") ...[
                    _buildFollowingFeed(context, player),
                  ],
                  const SizedBox(height: 100),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFollowingFeed(BuildContext context, PlayerService player) {
    final songComeMyWay = player.playlist.firstWhere((s) => s.title.toLowerCase().trim() == "come my way", orElse: () => player.playlist.firstWhere((s) => s.artist.contains("Sơn Tùng M-TP"), orElse: () => player.playlist[0]));
    final songTungQuen = player.playlist.firstWhere((s) => s.title.toLowerCase().trim() == "từng quen", orElse: () => player.playlist.firstWhere((s) => s.artist.contains("Wren Evans"), orElse: () => player.playlist[0]));
    final songDuaEmVeNha = player.playlist.firstWhere((s) => s.title.toLowerCase().trim() == "đưa em về nhàa", orElse: () => player.playlist.firstWhere((s) => s.artist.contains("GREY D"), orElse: () => player.playlist[0]));
    final songNeuLucDo = player.playlist.firstWhere((s) => s.title.toLowerCase().trim() == "nếu lúc đó", orElse: () => player.playlist.firstWhere((s) => s.artist.contains("tlinh"), orElse: () => player.playlist[0]));

    final List<Map<String, dynamic>> releases = [
      {
        "title": "tlinh",
        "subtitle": "nếu lúc đó",
        "timeAgo": "1 tuần trước",
        "trackInfo": "1 bài hát • nếu lúc đó",
        "imageUrl": songNeuLucDo.albumArt,
        "song": songNeuLucDo,
      },
      {
        "title": "Sơn Tùng M-TP, Tyga",
        "subtitle": "Come My Way",
        "timeAgo": "2 tuần trước",
        "trackInfo": "1 bài hát • Come My Way",
        "imageUrl": songComeMyWay.albumArt,
        "song": songComeMyWay,
      },
      {
        "title": "GREY D, Chillies",
        "subtitle": "đưa em về nhàa",
        "timeAgo": "2 tuần trước",
        "trackInfo": "1 bài hát • đưa em về nhàa",
        "imageUrl": songDuaEmVeNha.albumArt,
        "song": songDuaEmVeNha,
      },
      {
        "title": "Wren Evans",
        "subtitle": "Từng Quen (Future Bass Remix)",
        "timeAgo": "3 tuần trước",
        "trackInfo": "1 bài hát • Từng Quen",
        "imageUrl": songTungQuen.albumArt,
        "song": songTungQuen,
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Bản phát hành mới nhất"),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: releases.length,
          itemBuilder: (ctx, index) {
            final item = releases[index];
            final Song song = item["song"];
            final isLiked = player.isSongLiked(song);

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1B232E), // Premium dark-blue grayish card color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Album Art
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item["imageUrl"],
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF2E3B4E),
                            width: 88,
                            height: 88,
                            child: const Icon(Icons.music_note, color: Colors.white30, size: 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item["title"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item["subtitle"]} • ${item["timeAgo"]}",
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item["trackInfo"],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Controls Row
                  Row(
                    children: [
                      // Preview Button
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Đang xem trước: ${song.title}"),
                              backgroundColor: const Color(0xFF1E2631),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          player.playSong(song);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          child: const Row(
                            children: [
                              Icon(Icons.volume_mute, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                "Xem trước đĩa đơn",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Like/Plus Button
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.check_circle : Icons.add_circle_outline,
                          color: isLiked ? const Color(0xFF1ED760) : Colors.white60,
                          size: 28,
                        ),
                        onPressed: () => player.toggleLikeSong(song),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 20),
                      // Play Button
                      GestureDetector(
                        onTap: () {
                          final isCurrentSong = player.currentSong.title.toLowerCase().trim() == song.title.toLowerCase().trim();
                          if (isCurrentSong && player.isPlaying) {
                            player.pause();
                          } else if (isCurrentSong) {
                            player.play();
                          } else {
                            player.playSong(song);
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            (player.currentSong.title.toLowerCase().trim() == song.title.toLowerCase().trim() && player.isPlaying)
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPill(String text) {
    final isSelected = _selectedCategory == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1ED760) : const Color(0xFF282828),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpotifyPlaylistCard({
    required BuildContext context,
    required Song song,
    required String bannerText,
    required Color bannerColor,
    required Color textColor,
    required String subtitle,
    required Color spotifyIconColor,
    String? imageUrl,
    bool hasTextOverlay = false,
  }) {
    return GestureDetector(
      onTap: () {
        PlayerService().playSong(song);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đang phát: ${song.title}"),
            backgroundColor: song.themeColor,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 155,
                width: 155,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl ?? song.albumArt,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                bannerColor,
                                bannerColor.withOpacity(0.4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white24,
                            size: 48,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Spotify_logo_without_text.svg/1024px-Spotify_logo_without_text.svg.png",
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.music_note_sharp,
                          color: spotifyIconColor,
                          size: 16,
                        ),
                      ),
                    ),
                    if (!hasTextOverlay)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          color: bannerColor,
                          child: Text(
                            bannerText,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                    if (hasTextOverlay)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Text(
                          bannerText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(1, 1),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFA7A7A7),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioCard({
    required BuildContext context,
    required Song song,
    required Color color,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        PlayerService().playSong(song);
      },
      child: Container(
        width: 145,
        margin: const EdgeInsets.only(right: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 145,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Text(
                      "RADIO",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    left: 0,
                    child: Icon(
                      Icons.radio_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(song.albumArt),
                        ),
                        const SizedBox(width: 4),
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black12,
                          child: Icon(Icons.person, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFA7A7A7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicCategoryView(BuildContext context, PlayerService player) {
    final songSonTung = player.playlist.firstWhere((s) => s.artist.contains("Sơn Tùng M-TP"), orElse: () => player.playlist[0]);
    final songWren = player.playlist.firstWhere((s) => s.artist.contains("Wren Evans"), orElse: () => player.playlist[0]);
    final songTlinh = player.playlist.firstWhere((s) => s.artist.contains("tlinh"), orElse: () => player.playlist[0]);
    final songHieuThuHai = player.playlist.firstWhere((s) => s.artist.contains("HIEUTHUHAI"), orElse: () => player.playlist.length > 1 ? player.playlist[1] : player.playlist[0]);
    final songGreyD = player.playlist.firstWhere((s) => s.artist.contains("GREY D"), orElse: () => player.playlist[0]);

    // Build grid items dynamically using recently played items, with fallback to songs
    final List<Map<String, dynamic>> gridItems = [];
    final Set<String> seenTitles = {};

    for (final item in player.recentlyPlayedList) {
      if (gridItems.length >= 4) break;
      if (!seenTitles.contains(item.title)) {
        seenTitles.add(item.title);
        gridItems.add({
          'title': item.title,
          'imageUrl': item.type == 'artist'
              ? player.getArtistImageUrl(item.title, fallbackUrl: item.imageUrl)
              : item.imageUrl,
          'isCircularImage': item.type == 'artist',
          'onTap': () {
            if (item.type == 'artist') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtistDetailScreen(
                    artistName: item.title,
                  ),
                ),
              );
            } else if (item.type == 'song') {
              final songMatch = player.playlist.firstWhere(
                (s) => s.title.toLowerCase() == item.title.toLowerCase(),
                orElse: () => player.playlist.first,
              );
              player.playSong(songMatch);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Đang phát danh mục: ${item.title}"),
                  backgroundColor: const Color(0xFF1ED760),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
        });
      }
    }

    // Fallback to playlist songs if fewer than 4 items
    if (gridItems.length < 4) {
      final List<Song> fallbackSongs = [
        songSonTung,
        player.playlist.firstWhere((s) => s.title.toLowerCase() == "come my way", orElse: () => songSonTung),
        songHieuThuHai,
        songWren,
        songTlinh,
        songGreyD,
      ];
      for (final song in fallbackSongs) {
        if (gridItems.length >= 4) break;
        if (!seenTitles.contains(song.title)) {
          seenTitles.add(song.title);
          gridItems.add({
            'title': song.title,
            'imageUrl': song.albumArt,
            'isCircularImage': false,
            'onTap': () {
              player.playSong(song);
            }
          });
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Grid of 4 items
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.7,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: gridItems.map((item) {
            return _buildGridCard(
              title: item['title'] as String,
              imageUrl: item['imageUrl'] as String,
              isCircularImage: item['isCircularImage'] as bool,
              onTap: item['onTap'] as VoidCallback,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // 2. Section "Để bạn bắt đầu"
        _buildSectionHeader("Để bạn bắt đầu"),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSpotifyPlaylistCard(
                context: context,
                song: songSonTung,
                bannerText: "Tuyển tập của VCT",
                bannerColor: const Color(0xFF00E5FF),
                textColor: Colors.black,
                subtitle: "B Ray, HIEUTHUHAI và Sơn Tùng M-TP",
                spotifyIconColor: Colors.white,
                imageUrl: "https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=400&q=80",
              ),
              _buildSpotifyPlaylistCard(
                context: context,
                song: songHieuThuHai,
                bannerText: "Tuyển tập của VSTRA",
                bannerColor: const Color(0xFFFFB6C1),
                textColor: Colors.black,
                subtitle: "B Ray, HIEUTHUHAI và Sơn Tùng M-TP",
                spotifyIconColor: Colors.white,
                imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&q=80",
              ),
              _buildSpotifyPlaylistCard(
                context: context,
                song: songWren,
                bannerText: "Tuyển tập của Wren",
                bannerColor: const Color(0xFFFFCC80),
                textColor: Colors.black,
                subtitle: "Wren Evans, HIEUTHUHAI và MCK",
                spotifyIconColor: Colors.white,
                imageUrl: songWren.albumArt,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. Section "Hãy thử cách khác"
        _buildSectionHeader("Hãy thử cách khác"),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSpotifyPlaylistCard(
                context: context,
                song: songTlinh,
                bannerText: "Workday K-Pop\n내적댄스 업무/공부",
                bannerColor: Colors.black54,
                textColor: Colors.white,
                subtitle: "BTS, JENNIE, KATSEYE, CORTIS, BLACKPINK",
                spotifyIconColor: Colors.white,
                imageUrl: "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=400&q=80",
                hasTextOverlay: true,
              ),
              _buildSpotifyPlaylistCard(
                context: context,
                song: songGreyD,
                bannerText: "situationship",
                bannerColor: Colors.black54,
                textColor: Colors.white,
                subtitle: "Taylor Swift, The Weeknd, Olivia Rodrigo, Billie Eilish",
                spotifyIconColor: Colors.white,
                imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80",
                hasTextOverlay: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodcastsCategoryView(BuildContext context, PlayerService player) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 64, color: Color(0xFF1ED760)),
            const SizedBox(height: 16),
            const Text(
              "Podcasts dành cho bạn",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Các chương trình và nội dung nói chuyện sẽ hiển thị ở đây.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required String title,
    required String imageUrl,
    required bool isCircularImage,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            isCircularImage
                ? Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                  )
                : Image.network(
                    imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[800],
                      width: 56,
                      height: 56,
                      child: const Icon(Icons.music_note, color: Colors.white24),
                    ),
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}