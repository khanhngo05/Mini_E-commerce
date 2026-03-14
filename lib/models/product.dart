class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingData = json['rating'];
    final rate = ratingData is Map<String, dynamic> ? ratingData['rate'] : null;
    final count = ratingData is Map<String, dynamic>
        ? ratingData['count']
        : null;

    return Product(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      price: (json['price'] as num).toDouble(),
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      imageUrl: (json['image'] ?? '') as String,
      rating: (rate is num) ? rate.toDouble() : 0,
      ratingCount: (count is num) ? count.toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': imageUrl,
      'rating': {'rate': rating, 'count': ratingCount},
    };
  }

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? imageUrl,
    double? rating,
    int? ratingCount,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}
