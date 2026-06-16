import 'dart:convert';

class RecentlyPlayedItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String type; // 'artist', 'playlist', 'radio', 'song'
  final DateTime playedAt;
  final String details;
  final String? creator;
  final bool hasCheck;

  RecentlyPlayedItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    required this.playedAt,
    this.details = "",
    this.creator,
    this.hasCheck = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'type': type,
      'playedAt': playedAt.toIso8601String(),
      'details': details,
      'creator': creator,
      'hasCheck': hasCheck,
    };
  }

  factory RecentlyPlayedItem.fromMap(Map<String, dynamic> map) {
    return RecentlyPlayedItem(
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? 'song',
      playedAt: map['playedAt'] != null ? DateTime.parse(map['playedAt']) : DateTime.now(),
      details: map['details'] ?? '',
      creator: map['creator'],
      hasCheck: map['hasCheck'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory RecentlyPlayedItem.fromJson(String source) => RecentlyPlayedItem.fromMap(json.decode(source));
}
