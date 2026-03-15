class BannerItem {
  final String id;
  final String title;
  final String imageUrl;

  const BannerItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: (json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'imageUrl': imageUrl};
  }
}
