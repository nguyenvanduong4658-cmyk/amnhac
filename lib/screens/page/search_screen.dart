import 'package:flutter/material.dart';
import '../../services/player_service.dart';
import '../../models/song.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Song> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchResults = PlayerService().searchSongs(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {"name": "Nhạc Việt", "color": const Color(0xFFE8115B)},
      {"name": "K-Pop", "color": const Color(0xFF148A08)},
      {"name": "Pop", "color": const Color(0xFF537AA1)},
      {"name": "Hip-Hop", "color": const Color(0xFFBC5900)},
      {"name": "Dance & Electronic", "color": const Color(0xFF7358FF)},
      {"name": "Mới phát hành", "color": const Color(0xFFE1118C)},
      {"name": "Bảng xếp hạng", "color": const Color(0xFF8900E1)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Tìm kiếm",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              // Search Input field
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: false,
                style: const TextStyle(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: "Bạn muốn nghe gì?",
                  hintStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 24),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.black54),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Search results or categories
              Expanded(
                child: _isSearching
                    ? _buildSearchResultsList()
                    : _buildCategoriesGrid(categories),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy bài hát phù hợp.",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final song = _searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
            PlayerService().playSong(song);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Đang phát: ${song.title}"),
                backgroundColor: song.themeColor,
                duration: const Duration(seconds: 2),
              ),
            );
            // Hide keyboard
            FocusScope.of(context).unfocus();
          },
        );
      },
    );
  }

  Widget _buildCategoriesGrid(List<Map<String, dynamic>> categories) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Duyệt tìm tất cả",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  _searchController.text = cat["name"];
                  _searchFocusNode.requestFocus();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cat["color"],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Text(
                        cat["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        right: -20,
                        bottom: -10,
                        child: Transform.rotate(
                          angle: 0.4,
                          child: Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(-2, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white24,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80), // bottom spacer
        ],
      ),
    );
  }
}
