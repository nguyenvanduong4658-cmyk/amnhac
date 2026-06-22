import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/player_service.dart';
import '../../models/artist.dart';

class SelectArtistsScreen extends StatefulWidget {
  const SelectArtistsScreen({super.key});

  @override
  State<SelectArtistsScreen> createState() => _SelectArtistsScreenState();
}

class _SelectArtistsScreenState extends State<SelectArtistsScreen> {
  final player = PlayerService();
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  late List<Artist> _candidateArtists;
  final Set<String> _selectedArtistNames = {};

  @override
  void initState() {
    super.initState();
    
    // 1. Dynamic extraction from playlist (app's actual data)
    final Set<String> uniqueArtistNames = {};
    final List<Artist> list = [];

    for (final song in player.playlist) {
      String primaryArtist = song.artist;
      if (primaryArtist.contains("(ft.")) {
        primaryArtist = primaryArtist.split("(ft.")[0].trim();
      } else if (primaryArtist.contains(" x ")) {
        primaryArtist = primaryArtist.split(" x ")[0].trim();
      }
      
      final artistName = primaryArtist.trim();
      if (artistName.isNotEmpty && !uniqueArtistNames.contains(artistName.toLowerCase())) {
        uniqueArtistNames.add(artistName.toLowerCase());
        final imgUrl = player.getArtistImageUrl(artistName);
        list.add(Artist(name: artistName, imageUrl: imgUrl));
      }
    }

    // 2. Add candidates from screenshot that are not already present
    final screenshotArtists = [
      const Artist(name: "JustaTee", imageUrl: "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400&q=80"),
      const Artist(name: "Minh Vương M4U", imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80"),
      const Artist(name: "Lou Hoàng", imageUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80"),
      const Artist(name: "Yến Tatoo", imageUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&q=80"),
      const Artist(name: "Rhymastic", imageUrl: "https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=400&q=80"),
      const Artist(name: "ANH TRAI \"SAY HI\"", imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&q=80"),
      const Artist(name: "Donald Gold", imageUrl: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&q=80"),
      const Artist(name: "buitruonglinh", imageUrl: "https://images.unsplash.com/photo-1488161628813-04466f872be2?w=400&q=80"),
    ];

    for (final sa in screenshotArtists) {
      if (!uniqueArtistNames.contains(sa.name.toLowerCase())) {
        uniqueArtistNames.add(sa.name.toLowerCase());
        list.add(sa);
      }
    }

    _candidateArtists = list;

    for (final followed in player.followedArtists) {
      _selectedArtistNames.add(followed.name.toLowerCase());
    }
  }

  void _toggleSelection(Artist artist) {
    setState(() {
      final nameLower = artist.name.toLowerCase();
      if (_selectedArtistNames.contains(nameLower)) {
        _selectedArtistNames.remove(nameLower);
      } else {
        _selectedArtistNames.add(nameLower);
      }
    });
  }

  void _saveAndClose() async {
    for (final candidate in _candidateArtists) {
      final nameLower = candidate.name.toLowerCase();
      final isCurrentlyFollowed = player.followedArtists.any((a) => a.name.toLowerCase() == nameLower);
      final isSelectedNow = _selectedArtistNames.contains(nameLower);

      if (isSelectedNow && !isCurrentlyFollowed) {
        await player.addFollowedArtist(candidate.name, candidate.imageUrl);
      } else if (!isSelectedNow && isCurrentlyFollowed) {
        await player.removeFollowedArtist(candidate.name);
      }
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showAddCustomArtistPrompt() {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController imageCtrl = TextEditingController();
    String? localImagePath;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text("Thêm nghệ sĩ mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Tên nghệ sĩ",
                        hintStyle: TextStyle(color: Colors.white30),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Link ảnh nghệ sĩ (URL)",
                        hintStyle: TextStyle(color: Colors.white30),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("HOẶC", style: TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF282828),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setDialogState(() {
                            localImagePath = picked.path;
                          });
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: Text(localImagePath == null ? "Chọn ảnh từ thư viện" : "Đã chọn ảnh"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      final imgUrl = localImagePath ?? imageCtrl.text.trim();
                      setState(() {
                        final newArtist = Artist(name: name, imageUrl: imgUrl);
                        _candidateArtists.add(newArtist);
                        _selectedArtistNames.add(name.toLowerCase());
                      });
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text("Thêm", style: TextStyle(color: Color(0xFF1ED760), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayArtists = _candidateArtists.where((artist) {
      if (_searchQuery.isEmpty) return true;
      return artist.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final int otherCardIndex = displayArtists.length >= 6 ? 5 : displayArtists.length;
    final int totalCount = displayArtists.length + 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 12.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text(
                    "Chọn thêm các nghệ sĩ\nbạn thích.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.black54),
                        hintText: "Tìm kiếm",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 100.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: totalCount,
                    itemBuilder: (context, index) {
                      final isOtherCard = index == otherCardIndex;
                      
                      if (isOtherCard) {
                        return GestureDetector(
                          onTap: _showAddCustomArtistPrompt,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E3A8A),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(12),
                                  child: const Text(
                                    "Nghệ sĩ khác\ncó thể bạn sẽ\nthích",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "",
                                style: TextStyle(color: Colors.transparent, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }

                      final artistIndex = index > otherCardIndex ? index - 1 : index;
                      if (artistIndex >= displayArtists.length) return const SizedBox.shrink();

                      final artist = displayArtists[artistIndex];
                      final isSelected = _selectedArtistNames.contains(artist.name.toLowerCase());

                      return GestureDetector(
                        onTap: () => _toggleSelection(artist),
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF1ED760) : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: CircleAvatar(
                                      radius: double.infinity,
                                      backgroundImage: artist.imageUrl.startsWith('http')
                                          ? NetworkImage(artist.imageUrl)
                                          : FileImage(File(artist.imageUrl)) as ImageProvider,
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 4,
                                      bottom: 4,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1ED760),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.black,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              artist.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: SizedBox(
                  width: 140,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _saveAndClose,
                    child: const Text(
                      "Xong",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
