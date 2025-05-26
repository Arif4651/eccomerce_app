import 'package:ecommerce_app/model/model.dart';
import 'package:ecommerce_app/service/service.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/cartlist.dart'; // Import cartlist.dart
import 'package:ecommerce_app/whishlist.dart'; // Import whishlist.dart
import 'package:ecommerce_app/account.dart'; // Import account.dart
import 'package:ecommerce_app/product_detail_page.dart'; // Import product_detail.dart
import 'package:provider/provider.dart'; // Import provider
import 'package:ecommerce_app/cart_model.dart'; // Import CartModel
import 'package:ecommerce_app/widgets/cached_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<ProductElement>? products;
  var isLoad = false;
  int _selectedIndex = 0; // Added for bottom navigation
  Category? _selectedCategory; // Added to track selected category
  String _searchQuery = ''; // Added to store search query

  // TextEditingController for the search bar
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userName = 'User'; // Default name

  @override
  void initState() {
    super.initState();
    getData();
    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
    _updateUserName();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _searchController.dispose();
    super.dispose();
  }

  // Method to update search query and trigger rebuild
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _updateUserName() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        // Use display name if available, otherwise use email username
        _userName = user.displayName ?? (user.email?.split('@')[0] ?? 'User');
      });
    }
  }

  getData() async {
    products = await services().getpost();
    if (products != null) {
      setState(() {
        isLoad = true;
      });
    }
  }

  // Method to handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to different pages based on index
    switch (index) {
      case 0: // Home (Dashboard)
        // Already on Dashboard, do nothing or reset state if needed
        break;
      case 1: // Cart
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartListPage()),
        );
        break;
      case 2: // Wishlist
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WishlistPage()),
        );
        break;
      case 3: // Account
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final cartItemsCount = cartModel.itemQuantitiesMap.length;

    // Filter products based on selected category and search query
    List<ProductElement>? displayedProducts = products;

    if (_selectedCategory != null) {
      displayedProducts =
          displayedProducts
              ?.where((product) => product.category == _selectedCategory)
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      displayedProducts =
          displayedProducts
              ?.where(
                (product) =>
                    product.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    product.model.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ShopSphere')),
      body: Visibility(
        visible: isLoad,
        replacement: const Center(child: CircularProgressIndicator()),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message with User's Name
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
                child: Text(
                  'Welcome, $_userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xFFE5315D)),
                    ),
                  ),
                ),
              ),
              // Categories Section Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              // Categories List (Horizontal)
              Container(
                height: 40, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Category.values.length,
                  itemBuilder: (context, index) {
                    final category = Category.values[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(
                          category.name.capitalize(),
                          style: TextStyle(
                            color:
                                _selectedCategory == category
                                    ? Color(
                                      0xFFE5315D,
                                    ) // Text color when selected
                                    : Colors
                                        .black, // Text color when not selected
                          ),
                        ), // Capitalize for display
                        selected: _selectedCategory == category,
                        selectedColor:
                            Colors
                                .transparent, // Make selected color transparent
                        backgroundColor:
                            Colors
                                .grey[200], // Background color when not selected
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20.0,
                          ), // Adjust border radius as needed
                          side:
                              _selectedCategory == category
                                  ? BorderSide(color: Color(0xFFE5315D))
                                  : BorderSide(
                                    color: Colors.transparent,
                                  ), // No border when not selected
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                            // Clear search when category is selected/deselected
                            _searchController.clear();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Deals/Products Section Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Deals You Can\'t Miss',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              // Products Grid View (Expanded)
              Expanded(
                child: Consumer<CartModel>(
                  // Consume CartModel here
                  builder: (context, cart, child) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of items in each row
                        crossAxisSpacing:
                            8.0, // Horizontal spacing between items
                        mainAxisSpacing: 8.0, // Vertical spacing between items
                        childAspectRatio:
                            0.7, // Ratio of the extent of the main axis to the extent of the cross axis
                      ),
                      itemCount:
                          displayedProducts?.length ??
                          0, // Use displayed products count
                      itemBuilder: (context, index) {
                        final product =
                            displayedProducts![index]; // Use displayed products
                        // Check if the product is in the wishlist
                        final isWishlisted = cart.isWishlistItem(product);
                        return InkWell(
                          onTap: () async {
                            // Made onTap async
                            // Navigate to product detail page and wait for result
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductDetailPage(
                                      product: product,
                                    ), // Pass the product object
                              ),
                            );

                            // If a product is returned (Add to Cart was clicked)
                            if (result != null && result is ProductElement) {
                              // Add the product to the cart using CartModel
                              Provider.of<CartModel>(
                                context,
                                listen: false,
                              ).addItemWithQuantity(result);
                              // Optional: Show a confirmation Snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added ${result.title} to cart!',
                                  ),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Color(0xFFE5315D),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            elevation: 2.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row for the wishlist icon at the top right
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .end, // Align icon to the right
                                  children: [
                                    // Optional: Add product title here if needed at the top left
                                    // Expanded(child: Text(product.title, overflow: TextOverflow.ellipsis)),
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite_border,
                                      ), // Wishlist icon
                                      color:
                                          isWishlisted
                                              ? Color(0xFFE5315D)
                                              : Colors
                                                  .grey, // Change color based on wishlist status
                                      onPressed: () {
                                        // Toggle wishlist status
                                        if (isWishlisted) {
                                          cart.removeWishlistItem(product);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Removed ${product.title} from wishlist!',
                                              ),
                                              duration: Duration(seconds: 1),
                                              backgroundColor: Colors.blueGrey,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          );
                                        } else {
                                          cart.addWishlistItem(product);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Added ${product.title} to wishlist!',
                                              ),
                                              duration: Duration(seconds: 1),
                                              backgroundColor: Color(
                                                0xFFE5315D,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: CachedImage(
                                    imageUrl: product.localImagePath,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Price: Tk. ${product.price}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Model: ${product.model}',
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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

// Extension to capitalize enum names for display
extension StringCasingExtension on String {
  String capitalize() =>
      '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
}
