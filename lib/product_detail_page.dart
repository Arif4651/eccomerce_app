import 'package:flutter/material.dart';
import 'package:ecommerce_app/model/model.dart'; // Import ProductElement
import 'package:provider/provider.dart'; // Import provider
import 'package:ecommerce_app/cart_model.dart'; // Import CartModel
import 'package:ecommerce_app/widgets/cached_image.dart';
import 'package:ecommerce_app/dashboard.dart';
import 'package:ecommerce_app/cartlist.dart';
import 'package:ecommerce_app/whishlist.dart';
import 'package:ecommerce_app/account.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductElement product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedIndex =
      0; // Set to 0 (Home) as default since this is a detail page

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to different pages based on index
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
        break;
      case 1: // Cart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CartListPage()),
        );
        break;
      case 2: // Wishlist
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WishlistPage()),
        );
        break;
      case 3: // Account
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AccountPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final cartItemsCount = cartModel.itemQuantitiesMap.length;
    final isWishlisted = cartModel.isWishlistItem(widget.product);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
        actions: [
          // Wishlist Icon in AppBar
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? const Color(0xFFE5315D) : Colors.grey,
            ),
            onPressed: () {
              if (isWishlisted) {
                cartModel.removeWishlistItem(widget.product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Removed ${widget.product.title} from wishlist!',
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.blueGrey,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                );
              } else {
                cartModel.addWishlistItem(widget.product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${widget.product.title} to wishlist!'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: const Color(0xFFE5315D),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              height: 300,
              width: double.infinity,
              child: CachedImage(
                imageUrl: widget.product.localImagePath,
                fit: BoxFit.contain,
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product Price
                  Text(
                    'Price: Tk. ${widget.product.price}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product Model
                  if (widget.product.model.isNotEmpty)
                    Text(
                      'Model: ${widget.product.model}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  const SizedBox(height: 8),
                  // Product Color (if available)
                  if (widget.product.color != null &&
                      widget.product.color!.isNotEmpty)
                    Text(
                      'Color: ${widget.product.color}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  const SizedBox(height: 16),
                  // Product Description
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  // Add to Cart Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add the product to the cart using CartModel
                        cartModel.addItemWithQuantity(widget.product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${widget.product.title} to cart!',
                              style: const TextStyle(color: Colors.white),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color(0xFFE5315D),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                        // Navigate back after adding to cart
                        Navigator.pop(context, widget.product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5315D),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
