import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Furniture User';
    final userEmail = user?.email ?? 'user@furniture.com';

    final textPrimaryColor = Theme.of(context).colorScheme.primary;

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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            userEmail,
            style: const TextStyle(fontSize: 14, color: Color(0xFFC73659)),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileRow(
                  context,
                  icon: Icons.favorite,
                  color: const Color(0xFFA91D3A),
                  title: 'Favorite Items',
                  value: favoriteProvider.favoriteCount.toString(),
                ),
                Divider(color: const Color(0xFFC73659).withValues(alpha: 0.3), height: 1),
                _buildProfileRow(
                  context,
                  icon: Icons.shopping_cart,
                  color: const Color(0xFFC73659),
                  title: 'Cart Items',
                  value: cartProvider.totalItems.toString(),
                ),
                Divider(color: const Color(0xFFC73659).withValues(alpha: 0.3), height: 1),
                _buildProfileRow(
                  context,
                  icon: Icons.attach_money,
                  color: const Color(0xFFC73659),
                  title: 'Current Total',
                  value: '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                ),
                Divider(color: const Color(0xFFC73659).withValues(alpha: 0.3), height: 1),
                // Theme Toggle Settings Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: const Color(0xFFC73659),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Dark Mode',
                        style: TextStyle(fontSize: 16, color: textPrimaryColor),
                      ),
                      const Spacer(),
                      Switch(
                        value: themeProvider.isDarkMode,
                        activeThumbColor: const Color(0xFFC73659),
                        activeTrackColor: const Color(0xFFC73659).withValues(alpha: 0.5),
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
              // AuthGate يعيد البناء تلقائيًا عبر authStateChanges
              // نضمن العودة لجذر الـ Navigator لإزالة أي شاشات في الـ stack
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
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

  Widget _buildProfileRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    final textPrimaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: textPrimaryColor),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimaryColor),
          ),
        ],
      ),
    );
  }
}