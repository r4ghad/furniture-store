import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../repositories/cart_repository.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository;
  List<CartItem> _items = [];
  String? _userId;

  CartProvider(this._cartRepository);

  List<CartItem> get items => _items;

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Load cart from DB for a specific user
  Future<void> loadCartForUser(String userId) async {
    _userId = userId;
    final dbItems = await _cartRepository.getCartItems(userId);
    
    _items = dbItems.map((row) {
      return CartItem(
        product: Product(
          id: row['id'] as String,
          name: row['title'] as String,
          price: (row['price'] as num).toDouble(),
          imageUrl: row['image'] as String,
          category: '', // Not saved in SQLite database
          description: '', // Not saved in SQLite database
        ),
        quantity: row['quantity'] as int,
      );
    }).toList();
    
    notifyListeners();
  }

  // Clear memory on logout
  void clearCartOnLogout() {
    _userId = null;
    _items.clear();
    notifyListeners();
  }

  Future<void> addToCart(Product product) async {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();

    if (_userId != null) {
      await _cartRepository.addOrUpdateItem(
        userId: _userId!,
        id: product.id,
        title: product.name,
        price: product.price,
        image: product.imageUrl,
        quantity: 1,
      );
    }
  }

  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();

    if (_userId != null) {
      await _cartRepository.deleteItem(_userId!, productId);
    }
  }

  Future<void> increaseQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      final newQuantity = _items[index].quantity;
      notifyListeners();

      if (_userId != null) {
        await _cartRepository.updateItemQuantity(_userId!, productId, newQuantity);
      }
    }
  }

  Future<void> decreaseQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        final newQuantity = _items[index].quantity;
        notifyListeners();

        if (_userId != null) {
          await _cartRepository.updateItemQuantity(_userId!, productId, newQuantity);
        }
      } else {
        _items.removeAt(index);
        notifyListeners();

        if (_userId != null) {
          await _cartRepository.deleteItem(_userId!, productId);
        }
      }
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();

    if (_userId != null) {
      await _cartRepository.clearCart(_userId!);
    }
  }
}