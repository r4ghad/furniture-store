import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final textPrimaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorites',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your favorite items',
            style: TextStyle(color: Color(0xFFC73659), fontSize: 14),
          ),
          const SizedBox(height: 20),
          if (favoriteProvider.favorites.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Color(0xFFC73659),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: TextStyle(color: Color(0xFFC73659)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...favoriteProvider.favorites.map(
              (product) => _buildFavoriteCard(
                product,
                favoriteProvider,
                cartProvider,
                context,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    Product product,
    FavoriteProvider favoriteProvider,
    CartProvider cartProvider,
    BuildContext context,
  ) {
    final textPrimaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFECECEC),
                  child: const Icon(
                    Icons.image,
                    size: 40,
                    color: Color(0xFFC73659),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category.isNotEmpty ? product.category : 'Furniture',
                    style: const TextStyle(
                      color: Color(0xFFC73659),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFA91D3A),
                  ),
                  onPressed: () =>
                      favoriteProvider.removeFromFavorites(product.id),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Color(0xFFC73659),
                  ),
                  onPressed: () {
                    cartProvider.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Added to cart',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Color(0xFFA91D3A),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
