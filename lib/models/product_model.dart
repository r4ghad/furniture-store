class Product {
  final String id;
  final String name;
   String category;
  final String description;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final int? discountPercent;
  final String? timeLeft;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    this.discountPercent,
    this.timeLeft,
  });

  double get discountPercentage {
    if (oldPrice != null && oldPrice! > 0) {
      return ((oldPrice! - price) / oldPrice! * 100).roundToDouble();
    }
    return discountPercent?.toDouble() ?? 0;
  }

  // ✅ تحويل المنتج إلى JSON (لحفظه في Cache)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'discountPercent': discountPercent,
      'timeLeft': timeLeft,
    };
  }

  // ✅ تحويل JSON إلى منتج (لقراءته من API أو Cache الكامل)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      price: json['price'].toDouble(),
      oldPrice: json['oldPrice']?.toDouble(),
      imageUrl: json['imageUrl'],
      discountPercent: json['discountPercent'],
      timeLeft: json['timeLeft'],
    );
  }

  // ✅ تحويل JSON إلى منتج من ملف المفضلة (4 حقول فقط)
  factory Product.fromFavoriteJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: '',         // غير محفوظ في ملف المفضلة
      description: '',      // غير محفوظ في ملف المفضلة
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      oldPrice: null,
      discountPercent: null,
      timeLeft: null,
    );
  }
}