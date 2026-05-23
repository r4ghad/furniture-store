import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shopping Cart',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review your selected items',
            style: TextStyle(color: Color(0xFFC73659), fontSize: 14),
          ),
          const SizedBox(height: 20),
          if (cartProvider.items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: Color(0xFFC73659)),
                    SizedBox(height: 16),
                    Text('Your cart is empty', style: TextStyle(color: Color(0xFFC73659))),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ...cartProvider.items.map((item) => _buildCartItem(context, item, cartProvider)),
                const SizedBox(height: 24),
                _buildPaymentSummary(context, cartProvider),
                const SizedBox(height: 16),
                _buildCheckoutButton(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider cartProvider) {
    final textPrimaryColor = Theme.of(context).colorScheme.primary;

    return Container(
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
            child: Image.network(  // ✅ changed from Image.asset to Image.network
              item.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFECECEC),
                child: const Icon(Icons.image, size: 40, color: Color(0xFFC73659)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFFC73659)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFC73659)),
                      onPressed: () => cartProvider.decreaseQuantity(item.product.id),
                    ),
                    Text(
                      item.quantity.toString(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimaryColor),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC73659)),
                      onPressed: () => cartProvider.increaseQuantity(item.product.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimaryColor),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFA91D3A)),
                onPressed: () => cartProvider.removeFromCart(item.product.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Items', style: TextStyle(color: Color(0xFFC73659))),
              Text(
                cartProvider.totalItems.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: Color(0xFFC73659))),
              Text(
                '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC73659)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order confirmed successfully!'),
              backgroundColor: Color(0xFFA91D3A),
              duration: Duration(seconds: 2),
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
          'CHECKOUT',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }
}