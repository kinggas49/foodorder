import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  void addItem(String id, String name, double price, String image) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(id: id, name: name, price: price, image: image, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    if (_items.containsKey(id) && _items[id]!.quantity > 1) {
      _items[id]!.quantity -= 1;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void incrementItem(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
      notifyListeners();
    }
  }

  void decrementItem(String id) {
    if (_items.containsKey(id) && _items[id]!.quantity > 1) {
      _items[id]!.quantity--;
    } else if (_items.containsKey(id) && _items[id]!.quantity == 1) {
      _items.remove(id);
    }
    notifyListeners();
  }

  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.values.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  int getItemQuantity(String id) => _items.containsKey(id) ? _items[id]!.quantity : 0;

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({required this.id, required this.name, required this.price, required this.image, required this.quantity});
}
