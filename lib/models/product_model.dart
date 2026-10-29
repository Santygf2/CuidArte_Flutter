import '../core/network/api_client.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double? originalPrice;
  final int stock;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final bool isFeatured;
  final List<String> features;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.stock,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    this.isFeatured = false,
    this.features = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final featuresRaw = json['features'];
    final features = featuresRaw is List
        ? featuresRaw.map((item) => item.toString()).toList()
        : <String>[];

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      imageUrl: ApiClient.resolveUrl((json['image_url'] ?? '').toString()),
      isFeatured: json['is_featured'] == true,
      features: features,
    );
  }

  bool get inStock => stock > 0;
}
