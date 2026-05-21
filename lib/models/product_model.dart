import 'package:cloud_firestore/cloud_firestore.dart';

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

  // ✅ تحويل المنتج إلى Map لـ Firestore
  Map<String, dynamic> toMap() {
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

  // ✅ إنشاء منتج من DocumentSnapshot في Firestore
  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: data['oldPrice']?.toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      discountPercent: data['discountPercent'],
      timeLeft: data['timeLeft'],
    );
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