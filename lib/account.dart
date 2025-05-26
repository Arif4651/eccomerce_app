import 'package:flutter/material.dart';
import 'package:ecommerce_app/dashboard.dart'; // Import Dashboard
import 'package:ecommerce_app/cartlist.dart'; // Import CartListPage
import 'package:ecommerce_app/whishlist.dart'; // Import WishlistPage
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/homepage.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/cart_model.dart';
import 'package:ecommerce_app/services/user_data_service.dart'; // Import UserDataService
import 'package:ecommerce_app/widgets/cached_image.dart'; // Import CachedImage widget

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _selectedIndex = 3; // Set initial index for Account page
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoggingOut = false;
  final UserDataService _userDataService = UserDataService();
  List<Map<String, dynamic>> _orderHistory = [];
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    if (_user == null) return;

    setState(() => _isLoadingOrders = true);
    try {
      final orders = await _userDataService.getUserOrderHistory();
      if (mounted) {
        setState(() {
          _orderHistory = orders;
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      print('Error loading order history: $e');
      if (mounted) {
        setState(() => _isLoadingOrders = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      // Clear the cart and wishlist data (REMOVED TO PREVENT DELETION ON LOGOUT)
      // await Provider.of<CartModel>(context, listen: false).clearCart();
      // await Provider.of<CartModel>(context, listen: false).clearWishlist();

      // Sign out from Firebase
      await _auth.signOut();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Logged out successfully!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );

        // Navigate to homepage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Error logging out: ${e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to different pages based on index using pushReplacement
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
        break;
      case 1: // Cart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CartListPage()),
        );
        break;
      case 2: // Wishlist
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WishlistPage()),
        );
        break;
      case 3: // Account
        // Already on Account page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Information Section
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: const Text(
                'Profile Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfoRow(
                      'Email:',
                      _user?.email ?? 'Not signed in',
                    ),
                    const SizedBox(height: 8.0),
                    _buildProfileInfoRow(
                      'Username:',
                      _user?.displayName ?? 'Not set',
                    ),
                    const SizedBox(height: 8.0),
                    _buildProfileInfoRow(
                      'Account Created:',
                      _user?.metadata.creationTime?.toString().split(' ')[0] ??
                          'Unknown',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            // Order History Section
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (!_isLoadingOrders)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadOrderHistory,
                      tooltip: 'Refresh orders',
                    ),
                ],
              ),
            ),
            Expanded(
              child:
                  _isLoadingOrders
                      ? const Center(child: CircularProgressIndicator())
                      : _orderHistory.isEmpty
                      ? const Center(
                        child: Text(
                          'No orders yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _orderHistory.length,
                        itemBuilder: (context, index) {
                          final order = _orderHistory[index];
                          // Get the product ID from the order data
                          final productId = order['id'] ?? order['productId'];
                          print('Order data: $order'); // Debug log
                          print('Product ID: $productId'); // Debug log

                          return Card(
                            elevation: 2.0,
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: CachedImage(
                                        imageUrl:
                                            'asset/image/${productId}.jpg',
                                        fit: BoxFit.cover,
                                        errorWidget: Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  // Order Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order['productName'] ??
                                              'Unknown Product',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'Quantity: ${order['quantity']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '৳${(order['total'] ?? 0.0).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFE5315D),
                                              ),
                                            ),
                                            Text(
                                              '৳${(order['price'] ?? 0.0).toStringAsFixed(2)} each',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoggingOut ? null : _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5315D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoggingOut
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFE5315D),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
