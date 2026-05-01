class Product {
  final String id;
  final String name;
  final String category;
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
}