import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Back Button and Favorite Icon
            Stack(
              children: [
                Image.asset(
                  product.imageUrl,
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 350,
                    width: double.infinity,
                    color: const Color(0xFF1E1E1E),
                    child: const Icon(Icons.image, size: 80, color: Color(0xFFC73659)),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFEEEEEE)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      favoriteProvider.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                      color: favoriteProvider.isFavorite(product) ? const Color(0xFFA91D3A) : const Color(0xFFEEEEEE),
                      size: 28,
                    ),
                    onPressed: () => favoriteProvider.toggleFavorite(product),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.category,
                        style: const TextStyle(fontSize: 16, color: Color(0xFFC73659)),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, color: Color(0xFFC73659)),
                  ),
                  const SizedBox(height: 24),
                  if (product.oldPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Was: \$${product.oldPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(decoration: TextDecoration.lineThrough, color: Color(0xFFC73659)),
                      ),
                    ),
                  if (product.discountPercent != null)
                    Text(
                      '-${product.discountPercent}% OFF',
                      style: const TextStyle(color: Color(0xFFA91D3A), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cartProvider.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart'),
                            duration: Duration(seconds: 1),
                            backgroundColor: Color(0xFFA91D3A),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA91D3A),
                        foregroundColor: const Color(0xFFEEEEEE),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}