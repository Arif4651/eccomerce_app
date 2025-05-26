import 'package:flutter/material.dart';
import 'package:ecommerce_app/dashboard.dart'; // Import Dashboard
import 'package:ecommerce_app/account.dart'; // Import AccountPage
import 'package:ecommerce_app/whishlist.dart'; // Import WishlistPage
import 'package:ecommerce_app/model/model.dart'; // Import ProductElement
import 'package:provider/provider.dart'; // Import provider
import 'package:ecommerce_app/cart_model.dart'; // Import CartModel
import 'package:ecommerce_app/checkout.dart'; // Import Checkout
import 'package:ecommerce_app/widgets/cached_image.dart'; // Import CachedImage

class CartListPage extends StatefulWidget {
  // Removed cartItems parameter as it will be accessed via Provider
  const CartListPage({super.key});

  @override
  State<CartListPage> createState() => _CartlistState();
}

class _CartlistState extends State<CartListPage> {
  int _selectedIndex = 1; // Set initial index for Cart page
  // Removed _itemQuantities map as quantities are managed in CartModel

  // Removed initState as quantities are initialized in CartModel

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
        // Already on Cart page
        break;
      case 2: // Wishlist
        // Note: If WishlistPage also uses Provider for wishlist items, no argument is needed here.
        // Otherwise, you might need to pass wishlist items similar to how cart items were passed before.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WishlistPage()),
        );
        break;
      case 3: // Account
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccountPage()),
        );
        break;
    }
  }

  // Removed _calculateTotal method as it's in CartModel

  // Removed _updateQuantity method as it's in CartModel

  @override
  Widget build(BuildContext context) {
    // Access the CartModel using Provider
    final cart = Provider.of<CartModel>(context);
    final cartItemsMap =
        cart.itemQuantitiesMap; // Get the map of items and quantities
    final cartItemsList =
        cartItemsMap.keys.toList(); // Get the list of products
    final cartItemsCount = cartItemsMap.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body:
          cartItemsList.isEmpty
              ? Center(child: Text('Your cart is empty.'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          cartItemsList.length, // Use the list of products
                      itemBuilder: (context, index) {
                        final product = cartItemsList[index];
                        final quantity =
                            cartItemsMap[product] ??
                            0; // Get quantity from the map
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
                                    imageUrl: product.localImagePath,
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    // errorBuilder is handled within CachedImage
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Title
                                      Text(
                                        product.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                    ],
                                  ),
                                ),
                                // Quantity Controls
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                      ), // Minus icon
                                      onPressed:
                                          () => cart.removeItemWithQuantity(
                                            product,
                                          ), // Use CartModel method
                                    ),
                                    Text(
                                      '$quantity', // Display quantity
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_circle_outline,
                                      ), // Plus icon
                                      onPressed:
                                          () => cart.addItemWithQuantity(
                                            product,
                                          ), // Use CartModel method
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Total Price and Payment Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tk. ${cart.getTotalPriceFromMap().toStringAsFixed(2)}', // Use CartModel method
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to checkout page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Checkout(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE5315D),
                            padding: EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            textStyle: TextStyle(fontSize: 18),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Proceed to Payment',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                if (cartItemsCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5315D),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cartItemsCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE5315D),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
