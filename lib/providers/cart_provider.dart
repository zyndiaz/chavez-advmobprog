import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  // ignore: prefer_final_fields
  List<CartProduct> _items = [];

  List<CartProduct> get items => _items;

  int get totalItems {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      total += item.total;
    }
    return total;
  }

  void addItem(Product product) {
    final existingIndex = _items.indexWhere((item) => item.id == product.id);
    
    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      _items[existingIndex] = CartProduct(
        id: existing.id,
        title: existing.title,
        price: existing.price,
        quantity: existing.quantity + 1,
        total: existing.price * (existing.quantity + 1),
        discountPercentage: 0,
        discountedTotal: existing.price * (existing.quantity + 1),
        thumbnail: product.thumbnail,
      );
    } else {
      _items.add(CartProduct(
        id: product.id,
        title: product.title,
        price: product.price,
        quantity: 1,
        total: product.price,
        discountPercentage: 0,
        discountedTotal: product.price,
        thumbnail: product.thumbnail,
      ));
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == productId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        final item = _items[index];
        _items[index] = CartProduct(
          id: item.id,
          title: item.title,
          price: item.price,
          quantity: newQuantity,
          total: item.price * newQuantity,
          discountPercentage: 0,
          discountedTotal: item.price * newQuantity,
          thumbnail: item.thumbnail,
        );
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(int productId) {
    return _items.any((item) => item.id == productId);
  }

  int getQuantity(int productId) {
    final index = _items.indexWhere((item) => item.id == productId);
    if (index != -1) {
      return _items[index].quantity;
    }
    return 0;
  }
}