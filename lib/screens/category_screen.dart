import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = 'Living Rooms';
  late List<Product> _allProducts;
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _initProducts();
  }

  void _initProducts() {
    _allProducts = [
      // LIVING ROOMS
      Product(id: 'P1', name: 'Modern Sofa', category: 'Living Rooms', description: 'Luxury velvet sofa', price: 539.99, oldPrice: 899.99, imageUrl: 'assets/P1.jpeg', discountPercent: 40),
      Product(id: 'P2', name: 'Smart Coffee Table', category: 'Living Rooms', description: 'Coffee table with USB', price: 299.99, oldPrice: 499.99, imageUrl: 'assets/P2.jpeg', discountPercent: 40),
      Product(id: 'P3', name: 'Relaxing Armchair', category: 'Living Rooms', description: 'Comfortable armchair', price: 174.99, oldPrice: 249.99, imageUrl: 'assets/P3.jpeg', discountPercent: 30),
      Product(id: 'P4', name: 'Wool Handmade Rug', category: 'Living Rooms', description: 'Handmade wool rug', price: 159.99, oldPrice: 229.99, imageUrl: 'assets/P4.jpeg', discountPercent: 30),
      Product(id: 'P5', name: 'LED Floor Lamp', category: 'Living Rooms', description: 'LED floor lamp', price: 89.99, imageUrl: 'assets/P5.jpeg'),
      Product(id: 'P8', name: 'Wooden Dining Table', category: 'Living Rooms', description: 'Dining table', price: 449.99, imageUrl: 'assets/P8.jpeg'),
      Product(id: 'P9', name: 'Velvet Ottoman', category: 'Living Rooms', description: 'Velvet ottoman', price: 129.99, oldPrice: 199.99, imageUrl: 'assets/P9.jpeg', discountPercent: 35),
      Product(id: 'P10', name: 'Modern Desk', category: 'Living Rooms', description: 'Modern desk', price: 249.99, oldPrice: 399.99, imageUrl: 'assets/P10.jpeg', discountPercent: 37),

      // BEDROOMS
      Product(id: 'P6', name: 'Solid Wood Bed', category: 'Bedrooms', description: 'King size bed', price: 899.99, imageUrl: 'assets/P6.jpeg'),
      Product(id: 'P7', name: '4-Door Wardrobe', category: 'Bedrooms', description: 'Large wardrobe', price: 799.99, imageUrl: 'assets/P7.jpeg'),
      Product(id: 'P11', name: 'Nightstand Set', category: 'Bedrooms', description: 'Set of 2 nightstands', price: 149.99, oldPrice: 199.99, imageUrl: 'assets/P11.jpeg', discountPercent: 25),
      Product(id: 'P12', name: 'Dressing Table', category: 'Bedrooms', description: 'Dressing table with mirror', price: 249.99, imageUrl: 'assets/P12.jpeg'),

      // KITCHEN
      Product(id: 'P13', name: 'Dining Table Set', category: 'Kitchen', description: 'Table with 4 chairs', price: 449.99, imageUrl: 'assets/P13.jpeg'),
      Product(id: 'P14', name: 'Kitchen Island', category: 'Kitchen', description: 'Kitchen island with storage', price: 299.99, oldPrice: 399.99, imageUrl: 'assets/P14.jpeg', discountPercent: 25),
      Product(id: 'P15', name: 'Wall Shelf Set', category: 'Kitchen', description: 'Set of 3 shelves', price: 79.99, imageUrl: 'assets/P15.jpeg'),
      Product(id: 'P16', name: 'Kitchen Cabinet', category: 'Kitchen', description: 'Kitchen cabinet', price: 349.99, imageUrl: 'assets/P16.jpeg'),
    ];
    _filterProducts();
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _allProducts.where((p) => p.category == _selectedCategory).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categories', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE))),
          const SizedBox(height: 4),
          const Text('Browse furniture by category', style: TextStyle(color: Color(0xFFC73659), fontSize: 14)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildCategoryCard('Living Rooms', '🛋️', 'Living', const Color(0xFFA91D3A)),
              const SizedBox(width: 12),
              _buildCategoryCard('Bedrooms', '🛏️', 'Bedroom', const Color(0xFFC73659)),
              const SizedBox(width: 12),
              _buildCategoryCard('Kitchen', '🍳', 'Kitchen', const Color(0xFFA91D3A)),
            ],
          ),
          const SizedBox(height: 32),
          _buildCategoryTitle(),
          const SizedBox(height: 12),
          ..._filteredProducts.map((product) => _buildProductCard(product, favoriteProvider, cartProvider)),
          if (_filteredProducts.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No products', style: TextStyle(color: Color(0xFFC73659))))),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, String emoji, String shortName, Color color) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _selectedCategory = category; _filterProducts(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(colors: [color, color.withOpacity(0.7)]) : null,
            color: isSelected ? null : const Color(0xFF151515),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : const Color(0xFFC73659), width: 1.5),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(shortName, style: TextStyle(color: isSelected ? const Color(0xFFEEEEEE) : const Color(0xFFC73659), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
      case 'Living Rooms': title = '🛋️ Living Rooms'; sub = 'Comfortable & stylish furniture for your living space'; break;
      case 'Bedrooms': title = '🛏️ Bedrooms'; sub = 'Relaxing and cozy bedroom essentials'; break;
      case 'Kitchen': title = '🍳 Kitchen'; sub = 'Functional and modern kitchen furniture'; break;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE))), 
      const SizedBox(height: 4), 
      Text(sub, style: TextStyle(color: const Color(0xFFC73659), fontSize: 12))
    ]);
  }

  Widget _buildProductCard(Product product, FavoriteProvider favoriteProvider, CartProvider cartProvider) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(product.imageUrl, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: const Color(0xFF1E1E1E), child: const Icon(Icons.image, color: Color(0xFFC73659))))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE))), 
              Text(product.category, style: const TextStyle(color: Color(0xFFC73659), fontSize: 12)), 
              Text('\$${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)))
            ])),
            IconButton(onPressed: () { favoriteProvider.toggleFavorite(product); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(favoriteProvider.isFavorite(product) ? 'Added to favorites' : 'Removed from favorites'), duration: const Duration(milliseconds: 500), backgroundColor: const Color(0xFFA91D3A))); }, icon: Icon(favoriteProvider.isFavorite(product) ? Icons.favorite : Icons.favorite_border, color: favoriteProvider.isFavorite(product) ? const Color(0xFFA91D3A) : const Color(0xFFC73659))),
            IconButton(onPressed: () { cartProvider.addToCart(product); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart'), duration: Duration(milliseconds: 500), backgroundColor: Color(0xFFA91D3A))); }, icon: const Icon(Icons.add_circle, color: Color(0xFFC73659), size: 30)),
          ],
        ),
      ),
    );
  }
}