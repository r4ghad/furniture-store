import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Product> _trendingProducts;
  late List<Product> _mostRequestedProducts;

  @override
  void initState() {
    super.initState();
    _initProducts();
  }

  void _initProducts() {
    _trendingProducts = [
      Product(
        id: 'P4',
        name: 'Wool Handmade Rug',
        category: 'Living Rooms',
        description: 'Handmade natural wool rug',
        price: 159.99,
        oldPrice: 229.99,
        imageUrl: 'assets/P4.jpeg',
      ),
      Product(
        id: 'P9',
        name: 'Velvet Ottoman',
        category: 'Living Rooms',
        description: 'Stylish velvet ottoman',
        price: 129.99,
        oldPrice: 199.99,
        imageUrl: 'assets/P9.jpeg',
      ),
      Product(
        id: 'P14',
        name: 'Kitchen Island',
        category: 'Kitchen',
        description: 'Kitchen island with storage',
        price: 299.99,
        oldPrice: 399.99,
        imageUrl: 'assets/P14.jpeg',
      ),
    ];

    _mostRequestedProducts = [
      Product(
        id: 'P1',
        name: 'Modern Sofa',
        category: 'Living Rooms',
        description: 'Luxury velvet sofa',
        price: 539.99,
        oldPrice: 899.99,
        imageUrl: 'assets/P1.jpeg',
      ),
      Product(
        id: 'P2',
        name: 'Smart Coffee Table',
        category: 'Living Rooms',
        description: 'Coffee table with USB',
        price: 299.99,
        oldPrice: 499.99,
        imageUrl: 'assets/P2.jpeg',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TRENDING SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trending',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
                ),
                TextButton(
                  onPressed: () {
                    _showAllProductsDialog(context, 'Trending Products', _trendingProducts);
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
                itemCount: _trendingProducts.length,
                itemBuilder: (ctx, index) {
                  final product = _trendingProducts[index];
                  return _buildProductCard(product, favoriteProvider, cartProvider);
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
                ),
                TextButton(
                  onPressed: () {
                    _showAllProductsDialog(context, 'Most Requested Products', _mostRequestedProducts);
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
                itemCount: _mostRequestedProducts.length,
                itemBuilder: (ctx, index) {
                  final product = _mostRequestedProducts[index];
                  return _buildProductCard(product, favoriteProvider, cartProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, FavoriteProvider favoriteProvider, CartProvider cartProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    product.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: const Color(0xFF1E1E1E),
                      child: const Icon(Icons.image, size: 50, color: Color(0xFFC73659)),
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
                        favoriteProvider.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                        color: favoriteProvider.isFavorite(product) ? const Color(0xFFA91D3A) : const Color(0xFFEEEEEE),
                        size: 22,
                      ),
                      onPressed: () {
                        favoriteProvider.toggleFavorite(product);
                        _showFavoriteSnackbar(context, favoriteProvider.isFavorite(product));
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
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: const TextStyle(color: Color(0xFFC73659), fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFEEEEEE)),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.oldPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(decoration: TextDecoration.lineThrough, color: Color(0xFFC73659), fontSize: 12),
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
                    Icon(Icons.add_shopping_cart, size: 16, color: Color(0xFFEEEEEE)),
                    SizedBox(width: 6),
                    Text('Add to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllProductsDialog(BuildContext context, String title, List<Product> products) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

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
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductListItem(context, product, favoriteProvider, cartProvider);
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

  Widget _buildProductListItem(BuildContext context, Product product, FavoriteProvider favoriteProvider, CartProvider cartProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
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
              child: Image.asset(
                product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: const Color(0xFF1E1E1E),
                  child: const Icon(Icons.image, size: 30, color: Color(0xFFC73659)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE))),
                  Text(product.category, style: const TextStyle(color: Color(0xFFC73659), fontSize: 12)),
                  Text('\$${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE))),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                favoriteProvider.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                color: favoriteProvider.isFavorite(product) ? const Color(0xFFA91D3A) : const Color(0xFFC73659),
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
                  const SnackBar(content: Text('Added to cart'), duration: Duration(milliseconds: 500), backgroundColor: Color(0xFFA91D3A)),
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
        content: Text(isFav ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
        backgroundColor: isFav ? const Color(0xFFA91D3A) : const Color(0xFF151515),
      ),
    );
  }

  void _showCartSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFFA91D3A),
      ),
    );
  }
}