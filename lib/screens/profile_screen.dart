import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'furniture User';
    final userEmail = user?.email ?? 'user@furniture.com';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFA91D3A),
            child: Icon(Icons.person, size: 50, color: Color(0xFFEEEEEE)),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
          ),
          const SizedBox(height: 8),
          Text(
            userEmail,
            style: const TextStyle(fontSize: 14, color: Color(0xFFC73659)),
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
                  title: 'Favorite Items',
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
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout, color: Color(0xFFEEEEEE)),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: Color(0xFFEEEEEE), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA91D3A),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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