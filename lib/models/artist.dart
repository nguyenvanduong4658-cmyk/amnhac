class Artist {
  final String name;
  final String imageUrl;

  const Artist({
    required this.name,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'imageUrl': imageUrl,
      };

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
