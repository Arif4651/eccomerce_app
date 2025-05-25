import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/model/model.dart';

class UserDataService {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's cart items
  Future<Map<String, dynamic>> getUserCartItems() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('cartItems')) {
          return Map<String, dynamic>.from(data['cartItems']);
        }
      }
      return {};
    } catch (e) {
      print('Error getting cart items: $e');
      return {};
    }
  }

  // Save user's cart items
  Future<void> saveUserCartItems(Map<String, dynamic> cartItems) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'cartItems': cartItems,
        'lastUpdated': firestore.FieldValue.serverTimestamp(),
      }, firestore.SetOptions(merge: true));
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }

  // Get user's wishlist items
  Future<List<Map<String, dynamic>>> getUserWishlistItems() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('wishlistItems')) {
          final List<dynamic> wishlistData = data['wishlistItems'];
          return wishlistData
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting wishlist items: $e');
      return [];
    }
  }

  // Save user's wishlist items
  Future<void> saveUserWishlistItems(
    List<Map<String, dynamic>> wishlistItems,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'wishlistItems': wishlistItems,
        'lastUpdated': firestore.FieldValue.serverTimestamp(),
      }, firestore.SetOptions(merge: true));
    } catch (e) {
      print('Error saving wishlist items: $e');
    }
  }

  // Clear user's cart and wishlist
  Future<void> clearUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'cartItems': {},
        'wishlistItems': [],
        'lastUpdated': firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Save user's order history (matching wishlist pattern)
  Future<void> saveUserOrderHistory(
    List<Map<String, dynamic>> newOrderItems,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('saveUserOrderHistory: No user logged in');
      return;
    }

    try {
      print(
        'saveUserOrderHistory: Saving ${newOrderItems.length} new items for user ${user.uid}',
      );

      // First, get existing orders
      final doc = await _firestore.collection('users').doc(user.uid).get();
      List<Map<String, dynamic>> existingOrders = [];

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('orderHistory')) {
          final List<dynamic> orderHistoryData = data['orderHistory'];
          existingOrders =
              orderHistoryData
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList();
        }
      }

      // Combine existing orders with new orders
      final allOrders = [...existingOrders, ...newOrderItems];

      // Save the combined list
      await _firestore.collection('users').doc(user.uid).set({
        'orderHistory': allOrders,
        'lastUpdated': firestore.FieldValue.serverTimestamp(),
      }, firestore.SetOptions(merge: true));

      print(
        'saveUserOrderHistory: Successfully saved ${allOrders.length} total order items.',
      );
    } catch (e) {
      print('Error saving order history: $e');
      rethrow;
    }
  }

  // Get user's order history (matching wishlist pattern)
  Future<List<Map<String, dynamic>>> getUserOrderHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('getUserOrderHistory: No user logged in');
      return [];
    }

    try {
      print('getUserOrderHistory: Fetching order history for user ${user.uid}');
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('orderHistory')) {
          final List<dynamic> orderHistoryData = data['orderHistory'];
          final orderHistory =
              orderHistoryData
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList();
          print('getUserOrderHistory: Found ${orderHistory.length} items.');
          return orderHistory;
        }
      }
      return [];
    } catch (e) {
      print('Error getting order history: $e');
      return [];
    }
  }
}
