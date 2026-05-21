import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل المنتجات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final isLoading = productProvider.isLoading;
    final products = productProvider.products;
    final isOffline = productProvider.isOffline;

    // تقسيم المنتجات إلى Trending و Most Requested
    final trendingProducts = products.take(3).toList();
    final mostRequestedProducts = products.skip(3).take(2).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رسالة وضع غير متصل
            if (isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
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

            if (!isLoading && products.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No products found',
                    style: TextStyle(color: Color(0xFFC73659)),
                  ),
                ),
              ),

            if (!isLoading && products.isNotEmpty) ...[
              // TRENDING SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trending',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showAllProductsDialog(
                        context,
                        'Trending Products',
                        trendingProducts,
                      );
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(color: Color(0xFFC73659), fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Most loved styles right now',
                style: TextStyle(color: Color(0xFFC73659), fontSize: 14),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingProducts.length,
                  itemBuilder: (ctx, index) {
                    final product = trendingProducts[index];
                    return _buildProductCard(
                      product,
                      favoriteProvider,
                      cartProvider,
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // MOST REQUESTED SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Most Requested',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showAllProductsDialog(
                        context,
                        'Most Requested Products',
                        mostRequestedProducts,
                      );
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(color: Color(0xFFC73659), fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Our customers favorite picks',
                style: TextStyle(color: Color(0xFFC73659), fontSize: 14),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mostRequestedProducts.length,
                  itemBuilder: (ctx, index) {
                    final product = mostRequestedProducts[index];
                    return _buildProductCard(
                      product,
                      favoriteProvider,
                      cartProvider,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    Product product,
    FavoriteProvider favoriteProvider,
    CartProvider cartProvider,
  ) {
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
        width: 200,
        height: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: const Color(0xFF1E1E1E),
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Color(0xFFC73659),
                      ),
                    ),
                  ),
                ),
                // FAVORITE BUTTON
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        favoriteProvider.isFavorite(product)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: favoriteProvider.isFavorite(product)
                            ? const Color(0xFFA91D3A)
                            : const Color(0xFFEEEEEE),
                        size: 22,
                      ),
                      onPressed: () async {
                        final wasFavorite = favoriteProvider.isFavorite(
                          product,
                        );
                        await favoriteProvider.toggleFavorite(product);
                        // ننتظر لحظة حتى يحدث الـ stream ثم نعرض الرسالة
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (context.mounted) {
                          _showFavoriteSnackbar(
                            context,
                            !wasFavorite, // نعرض العكس لأن الـ stream لم يحدث بعد
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            // PRODUCT INFO
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Color(0xFFC73659),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.oldPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFFC73659),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // ADD TO CART BUTTON
            Container(
              margin: const EdgeInsets.all(8),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cartProvider.addToCart(product);
                  _showCartSnackbar(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA91D3A),
                  foregroundColor: const Color(0xFFEEEEEE),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_shopping_cart,
                      size: 16,
                      color: Color(0xFFEEEEEE),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEEEEEE),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllProductsDialog(
    BuildContext context,
    String title,
    List<Product> products,
  ) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC73659),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductListItem(
                        context,
                        product,
                        favoriteProvider,
                        cartProvider,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProductListItem(
    BuildContext context,
    Product product,
    FavoriteProvider favoriteProvider,
    CartProvider cartProvider,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: const Color(0xFF1E1E1E),
                  child: const Icon(
                    Icons.image,
                    size: 30,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                favoriteProvider.isFavorite(product)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoriteProvider.isFavorite(product)
                    ? const Color(0xFFA91D3A)
                    : const Color(0xFFC73659),
              ),
              onPressed: () {
                favoriteProvider.toggleFavorite(product);
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFC73659)),
              onPressed: () {
                cartProvider.addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to cart'),
                    duration: Duration(milliseconds: 500),
                    backgroundColor: Color(0xFFA91D3A),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFavoriteSnackbar(BuildContext context, bool isFav) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFav ? 'Added to favorites' : 'Removed from favorites',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFA91D3A),
      ),
    );
  }

  void _showCartSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Added to cart',
          style: const TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFFA91D3A),
      ),
    );
  }
}
