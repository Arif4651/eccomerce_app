import 'package:flutter/material.dart';
import 'package:ecommerce_app/dashboard.dart'; // Import Dashboard
import 'package:ecommerce_app/cartlist.dart'; // Import CartListPage
import 'package:ecommerce_app/account.dart'; // Import AccountPage
import 'package:ecommerce_app/model/model.dart'; // Import ProductElement
import 'package:provider/provider.dart'; // Import provider
import 'package:ecommerce_app/cart_model.dart'; // Import CartModel
import 'package:ecommerce_app/widgets/cached_image.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  int _selectedIndex = 2; // Set initial index for Wishlist page

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
        // Note: If CartListPage also uses Provider for cart items, no argument is needed here.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CartListPage()),
        );
        break;
      case 2: // Wishlist
        // Already on Wishlist page
        break;
      case 3: // Account
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccountPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the CartModel using Provider
    final cart = Provider.of<CartModel>(context);
    final wishlistItems = cart.wishlistItems; // Get the wishlist items

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body:
          wishlistItems.isEmpty
              ? Center(child: Text('Your wishlist is empty.'))
              : ListView.builder(
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final product = wishlistItems[index];
                  return Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Product Image
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CachedImage(
                              imageUrl: product.image,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Title
                                Text(
                                  product.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                // Product Model
                                if (product.model.isNotEmpty)
                                  Text(
                                    'Model: ${product.model}',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                const SizedBox(height: 4.0),
                                // Product Price
                                Text(
                                  'Tk. ${product.price}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                // Add to Cart Button
                                ElevatedButton(
                                  onPressed: () {
                                    // Add to cart
                                    cart.addItemWithQuantity(product);
                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added ${product.title} to cart!',
                                        ),
                                        duration: Duration(seconds: 1),
                                        backgroundColor: Color(0xFFE5315D),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                      ),
                                    );
                                    // Navigate to cart page
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CartListPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFE5315D),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size(100, 36),
                                  ),
                                  child: Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Remove from Wishlist Button
                          IconButton(
                            icon: Icon(Icons.delete_outline), // Delete icon
                            onPressed: () {
                              cart.removeWishlistItem(
                                product,
                              ); // Remove from wishlist
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Removed ${product.title} from wishlist!',
                                  ),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Colors.blueGrey,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Home icon
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), // Cart icon
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border), // Wishlist icon
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Profile/Account icon
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFE5315D), // Customize selected item color
        unselectedItemColor: Colors.grey, // Customize unselected item color
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
      ),
    );
  }
}
