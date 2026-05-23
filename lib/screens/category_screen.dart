import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = 'Living Rooms';

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    return allProducts.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final isLoading = productProvider.isLoading;
    final allProducts = productProvider.products;
    final filteredProducts = _getFilteredProducts(allProducts);
    final isOffline = productProvider.isOffline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رسالة وضع غير متصل
            if (isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFA91D3A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA91D3A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, size: 16, color: Color(0xFFC73659)),
                    SizedBox(width: 8),
                    Text(
                      'Offline mode - showing cached products',
                      style: TextStyle(color: Color(0xFFC73659), fontSize: 12),
                    ),
                  ],
                ),
              ),

            // أزرار التصنيفات
            Row(
              children: [
                _buildCategoryCard(
                  'Living Rooms',
                  '🛋️',
                  'Living',
                  const Color(0xFFA91D3A),
                ),
                const SizedBox(width: 12),
                _buildCategoryCard(
                  'Bedrooms',
                  '🛏️',
                  'Bedroom',
                  const Color(0xFFA91D3A),
                ),
                const SizedBox(width: 12),
                _buildCategoryCard(
                  'Kitchen',
                  '🍳',
                  'Kitchen',
                  const Color(0xFFA91D3A),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _buildCategoryTitle(),

            const SizedBox(height: 12),

            // شاشة التحميل
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFFC73659)),
                      SizedBox(height: 16),
                      Text(
                        'Loading products...',
                        style: TextStyle(color: Color(0xFFEEEEEE)),
                      ),
                    ],
                  ),
                ),
              ),

            if (!isLoading && allProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No products found',
                    style: TextStyle(color: Color(0xFFC73659)),
                  ),
                ),
              ),

            if (!isLoading && allProducts.isNotEmpty)
              ...filteredProducts.map(
                (product) =>
                    _buildProductCard(product, favoriteProvider, cartProvider),
              ),

            if (!isLoading && allProducts.isNotEmpty && filteredProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No products in this category',
                    style: TextStyle(color: Color(0xFFC73659)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String category,
    String emoji,
    String shortName,
    Color color,
  ) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedCategory = category;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [color, color.withOpacity(0.7)])
                : null,
            color: isSelected ? null : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                shortName,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFEEEEEE)
                      : const Color(0xFFC73659),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTitle() {
    String title = '';
    String sub = '';
    switch (_selectedCategory) {
      case 'Living Rooms':
        title = '🛋️ Living Rooms';
        sub = 'Comfortable & stylish furniture for your living space';
        break;
      case 'Bedrooms':
        title = '🛏️ Bedrooms';
        sub = 'Relaxing and cozy bedroom essentials';
        break;
      case 'Kitchen':
        title = '🍳 Kitchen';
        sub = 'Functional and modern kitchen furniture';
        break;
      case 'Home Decoration':
        title = '🏠 Home Decoration';
        sub = 'Beautiful decorations for your home';
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: const TextStyle(color: Color(0xFFC73659), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    Product product,
    FavoriteProvider favoriteProvider,
    CartProvider cartProvider,
  ) {
    final textPrimaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFECECEC),
                  child: const Icon(Icons.image, color: Color(0xFFC73659)),
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
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Color(0xFFC73659),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final wasFavorite = favoriteProvider.isFavorite(product);
                await favoriteProvider.toggleFavorite(product);
                await Future.delayed(const Duration(milliseconds: 200));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        !wasFavorite
                            ? 'Added to favorites'
                            : 'Removed from favorites',
                        style: const TextStyle(color: Colors.white),
                      ),
                      duration: const Duration(milliseconds: 500),
                      backgroundColor: const Color(0xFFA91D3A),
                    ),
                  );
                }
              },
              icon: Icon(
                favoriteProvider.isFavorite(product)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoriteProvider.isFavorite(product)
                    ? const Color(0xFFA91D3A)
                    : const Color(0xFFC73659),
              ),
            ),
            IconButton(
              onPressed: () {
                cartProvider.addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Added to cart',
                      style: TextStyle(color: Colors.white),
                    ),
                    duration: Duration(milliseconds: 500),
                    backgroundColor: Color(0xFFA91D3A),
                  ),
                );
              },
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFFC73659),
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
