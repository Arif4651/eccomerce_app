import 'package:flutter/foundation.dart';
import 'package:ecommerce_app/model/model.dart'; // Import ProductElement
import 'package:ecommerce_app/services/user_data_service.dart';

class CartModel extends ChangeNotifier {
  final UserDataService _userDataService = UserDataService();
  final Map<ProductElement, int> _itemQuantitiesMap = {};
  final List<ProductElement> _wishlistItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<ProductElement, int> get itemQuantitiesMap => _itemQuantitiesMap;
  List<ProductElement> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize cart and wishlist from Firestore
  Future<void> initializeUserData() async {
    _isLoading = true;
    _error = null; // Clear previous errors
    notifyListeners(); // Notify listeners about loading state

    try {
      print('CartModel: Initializing user data');

      // Load cart items
      print('CartModel: Calling getUserCartItems');
      final cartData = await _userDataService.getUserCartItems();
      print('CartModel: Received cartData: $cartData');
      _itemQuantitiesMap.clear();

      if (cartData.isNotEmpty) {
        print('CartModel: Processing ${cartData.length} cart items');
        // Convert stored data back to ProductElement objects
        for (var entry in cartData.entries) {
          try {
            final productData = Map<String, dynamic>.from(entry.value);
            print(
              'CartModel: Attempting to parse cart item: ${productData['id']}',
            );
            final product = ProductElement.fromJson(productData);

            if (product.title == null ||
                product.image == null ||
                product.description == null ||
                product.brand == null ||
                product.model == null) {
              print(
                'CartModel: Parsed cart item has unexpected null in non-nullable field: ${product.id}',
              );
              continue; // Skip this item if it has null in a required field
            }
            print(
              'CartModel: Successfully parsed cart item with ID ${product.id}',
            );

            _itemQuantitiesMap[product] = productData['quantity'] as int;
            print(
              'CartModel: Successfully loaded cart item: ${product.title} with quantity ${productData['quantity']}',
            );
          } catch (e) {
            print(
              'CartModel: ERROR during cart item parsing for ID ${entry.key}: ${e.toString()}',
            );
          }
        }
        print(
          'CartModel: Finished processing cart items. Map size: ${_itemQuantitiesMap.length}',
        );
      } else {
        print('CartModel: cartData is empty, no cart items to load.');
      }

      // Load wishlist items (keep existing logic for wishlist for now)
      print('CartModel: Calling getUserWishlistItems');
      final wishlistData = await _userDataService.getUserWishlistItems();
      print('CartModel: Received wishlistItems: $wishlistData');
      _wishlistItems.clear();

      if (wishlistData.isNotEmpty) {
        print('CartModel: Processing ${wishlistData.length} wishlist items');
        for (var itemData in wishlistData) {
          try {
            final product = ProductElement.fromJson(itemData);

            if (product.title == null ||
                product.image == null ||
                product.description == null ||
                product.brand == null ||
                product.model == null) {
              print(
                'CartModel: Parsed wishlist item has unexpected null in non-nullable field: ${product.id}',
              );
              continue; // Skip this item if it has null in a required field
            }
            print(
              'CartModel: Successfully parsed wishlist item with ID ${product.id}',
            );

            _wishlistItems.add(product);
            print(
              'CartModel: Successfully loaded wishlist item: ${product.title}',
            );
          } catch (e) {
            print(
              'CartModel: ERROR during wishlist item parsing: ${e.toString()}',
            );
          }
        }
        print(
          'CartModel: Finished processing wishlist items. List size: ${_wishlistItems.length}',
        );
      } else {
        print('CartModel: wishlistData is empty, no wishlist items to load.');
      }

      print('CartModel: Initialization complete.');
    } catch (e) {
      print('CartModel: Error during initialization: $e');
      _error = 'Failed to load user data: ${e.toString()}';
    } finally {
      _isLoading = false;
      // Ensure notifyListeners is called even if there's a parsing error in the loop
      print('CartModel: Calling notifyListeners in finally block.');
      notifyListeners();
    }
  }

  // Convert ProductElement to Map for storage
  Map<String, dynamic> _productToMap(ProductElement product) {
    final map = {
      'id': product.id,
      'title': product.title,
      'price': product.price,
      'description': product.description,
      'category': product.category.name, // Save category name as string
      'image': product.image,
      'model': product.model,
      'brand': product.brand, // Include the brand field
      // Include other nullable fields if needed, checking for null
      'color': product.color,
      'discount': product.discount,
      'popular': product.popular,
      'onSale': product.onSale,
    };
    print('CartModel: Converting product to map: $map');
    return map;
  }

  // Save cart items to Firestore
  Future<void> _saveCartItems() async {
    Map<String, dynamic> cartData = {};
    for (var entry in _itemQuantitiesMap.entries) {
      cartData[entry.key.id.toString()] = {
        ..._productToMap(entry.key),
        'quantity': entry.value,
      };
    }
    await _userDataService.saveUserCartItems(cartData);
  }

  // Save wishlist items to Firestore
  Future<void> _saveWishlistItems() async {
    List<Map<String, dynamic>> wishlistData =
        _wishlistItems.map((item) => _productToMap(item)).toList();
    await _userDataService.saveUserWishlistItems(wishlistData);
  }

  // Add item to cart
  Future<void> addItemWithQuantity(ProductElement product) async {
    if (_itemQuantitiesMap.containsKey(product)) {
      _itemQuantitiesMap[product] = (_itemQuantitiesMap[product] ?? 0) + 1;
    } else {
      _itemQuantitiesMap[product] = 1;
    }
    await _saveCartItems();
    notifyListeners();
  }

  // Remove item from cart
  Future<void> removeItemWithQuantity(ProductElement product) async {
    if (_itemQuantitiesMap.containsKey(product)) {
      if (_itemQuantitiesMap[product]! > 1) {
        _itemQuantitiesMap[product] = _itemQuantitiesMap[product]! - 1;
      } else {
        _itemQuantitiesMap.remove(product);
      }
      await _saveCartItems();
      notifyListeners();
    }
  }

  // Add to wishlist
  Future<void> addWishlistItem(ProductElement product) async {
    if (!_wishlistItems.contains(product)) {
      _wishlistItems.add(product);
      await _saveWishlistItems();
      notifyListeners();
    }
  }

  // Remove from wishlist
  Future<void> removeWishlistItem(ProductElement product) async {
    _wishlistItems.remove(product);
    await _saveWishlistItems();
    notifyListeners();
  }

  // Check if item is in wishlist
  bool isWishlistItem(ProductElement product) {
    return _wishlistItems.contains(product);
  }

  // Calculate total price
  double getTotalPriceFromMap() {
    return _itemQuantitiesMap.entries.fold(
      0.0,
      (total, entry) => total + (entry.key.price * entry.value),
    );
  }

  // Clear cart
  Future<void> clearCart() async {
    _itemQuantitiesMap.clear();
    await _saveCartItems();
    notifyListeners();
  }

  // Clear wishlist
  Future<void> clearWishlist() async {
    _wishlistItems.clear();
    await _saveWishlistItems();
    notifyListeners();
  }
}
