import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFC73659),
            child: Icon(Icons.person, size: 50, color: Color(0xFFEEEEEE)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gadget User',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
          ),
          const SizedBox(height: 8),
          const Text(
            'user@gadgetrental.com',
            style: TextStyle(fontSize: 14, color: Color(0xFFC73659)),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildProfileRow(
                  icon: Icons.favorite,
                  color: const Color(0xFFA91D3A),
                  title: 'Favorite Devices',
                  value: favoriteProvider.favoriteCount.toString(),
                ),
                const Divider(color: Color(0xFFC73659), height: 1),
                _buildProfileRow(
                  icon: Icons.shopping_cart,
                  color: const Color(0xFFC73659),
                  title: 'Cart Items',
                  value: cartProvider.totalItems.toString(),
                ),
                const Divider(color: Color(0xFFC73659), height: 1),
                _buildProfileRow(
                  icon: Icons.attach_money,
                  color: const Color(0xFFC73659),
                  title: 'Current Total',
                  value: '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Color(0xFFEEEEEE)),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
          ),
        ],
      ),
    );
  }
}