import 'package:flutter/foundation.dart';
import 'package:ecommerce_app/model/model.dart'; // Import ProductElement

class CartModel extends ChangeNotifier {
  // The private list of items in the cart.
  final List<ProductElement> _items = [];

  // An unmodifiable view of the items in the cart.
  List<ProductElement> get items => _items.toList();

  // Adds an item to the cart.
  void addItem(ProductElement item) {
    _items.add(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  // Removes all items from the cart.
  void removeAll() {
    _items.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  // Method to update item quantity (basic implementation for now)
  void updateItemQuantity(ProductElement item, int quantityChange) {
    int index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      // For simplicity with just a list, we'll remove and re-add based on quantity.
      // A Map<ProductElement, int> would be better for storing quantities directly.
      // This basic implementation will add/remove the item itself.
      if (quantityChange > 0) {
        for (int i = 0; i < quantityChange; i++) {
          _items.add(item);
        }
      } else if (quantityChange < 0) {
        for (int i = 0; i < quantityChange.abs(); i++) {
          _items.remove(item);
        }
      }
      notifyListeners();
    }
    // Note: A more robust implementation would use a Map to track quantities
    // like Map<ProductElement, int> _itemQuantities = {};
    // And update the quantity in the map.
  }

  // A more robust method to add/update quantity using a Map
  final Map<ProductElement, int> _itemQuantitiesMap = {};

  Map<ProductElement, int> get itemQuantitiesMap =>
      Map.unmodifiable(_itemQuantitiesMap);

  void addItemWithQuantity(ProductElement item) {
    if (_itemQuantitiesMap.containsKey(item)) {
      _itemQuantitiesMap[item] = (_itemQuantitiesMap[item] ?? 0) + 1;
    } else {
      _itemQuantitiesMap[item] = 1;
    }
    notifyListeners();
  }

  void removeItemWithQuantity(ProductElement item) {
    if (_itemQuantitiesMap.containsKey(item)) {
      if ((_itemQuantitiesMap[item] ?? 0) > 1) {
        _itemQuantitiesMap[item] = (_itemQuantitiesMap[item] ?? 0) - 1;
      } else {
        _itemQuantitiesMap.remove(item);
      }
      notifyListeners();
    }
  }

  // Method to calculate total price from the map
  double getTotalPriceFromMap() {
    double total = 0.0;
    _itemQuantitiesMap.forEach((item, quantity) {
      total += item.price * quantity;
    });
    return total;
  }

  // Clear the cart map
  void clearCartMap() {
    _itemQuantitiesMap.clear();
    notifyListeners();
  }

  // ********* Wishlist Section *********

  final List<ProductElement> _wishlistItems = [];

  List<ProductElement> get wishlistItems => _wishlistItems.toList();

  void addWishlistItem(ProductElement item) {
    if (!_wishlistItems.any((element) => element.id == item.id)) {
      // Prevent duplicates
      _wishlistItems.add(item);
      notifyListeners();
    }
  }

  void removeWishlistItem(ProductElement item) {
    _wishlistItems.removeWhere((element) => element.id == item.id);
    notifyListeners();
  }

  bool isWishlistItem(ProductElement item) {
    return _wishlistItems.any((element) => element.id == item.id);
  }
}
