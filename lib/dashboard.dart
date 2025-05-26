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
  int _selectedIndex = 0;
  Category? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userName = 'User';
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _isSearchVisible = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
    _updateUserName();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoad = false;
    });
    await getData();
  }

  Future<void> _refreshDashboard() async {
    // Reset all states
    setState(() {
      _selectedCategory = null;
      _searchQuery = '';
      _searchController.clear();
      _isSearchVisible = false;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    // Refresh data
    await _initializeData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final scrollPercentage = (currentScroll / maxScroll).clamp(0.0, 1.0);

    setState(() {
      _scrollProgress = scrollPercentage;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchController.clear();
        Future.delayed(const Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(FocusNode());
        });
      }
    });
  }

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
    if (index == 0) {
      // If home is clicked, refresh the dashboard
      _refreshDashboard();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      // Navigate to different pages based on index
      switch (index) {
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
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final cartItemsCount = cartModel.itemQuantitiesMap.length;

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
      appBar: AppBar(
        title: const Text('ShopSphere'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _toggleSearch),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshDashboard,
        child: Stack(
          children: [
            // Main scrollable content
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  _onScroll();
                }
                return true;
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Welcome Message
                  SliverToBoxAdapter(
                    child: AnimatedOpacity(
                      opacity: 1 - _scrollProgress,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Welcome, $_userName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Categories Section (Fixed)
                  SliverToBoxAdapter(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: Category.values.length,
                              itemBuilder: (context, index) {
                                final category = Category.values[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(
                                      category.name.capitalize(),
                                      style: TextStyle(
                                        color:
                                            _selectedCategory == category
                                                ? const Color(0xFFE5315D)
                                                : Colors.black,
                                      ),
                                    ),
                                    selected: _selectedCategory == category,
                                    selectedColor: Colors.transparent,
                                    backgroundColor: Colors.grey[200],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side:
                                          _selectedCategory == category
                                              ? const BorderSide(
                                                color: Color(0xFFE5315D),
                                              )
                                              : BorderSide.none,
                                    ),
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory =
                                            selected ? category : null;
                                        _searchController.clear();
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Deals Section Title with fade out
                  SliverToBoxAdapter(
                    child: AnimatedOpacity(
                      opacity: 1 - _scrollProgress,
                      duration: const Duration(milliseconds: 200),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Deals You Can\'t Miss',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Products Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.7,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = displayedProducts![index];
                        final isWishlisted = cartModel.isWishlistItem(product);
                        return ProductCard(
                          product: product,
                          isWishlisted: isWishlisted,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProductDetailPage(product: product),
                              ),
                            );
                          },
                          onWishlistToggle: () {
                            if (isWishlisted) {
                              cartModel.removeWishlistItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Removed ${product.title} from wishlist!',
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
                              cartModel.addWishlistItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added ${product.title} to wishlist!',
                                  ),
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
                        );
                      }, childCount: displayedProducts?.length ?? 0),
                    ),
                  ),
                ],
              ),
            ),
            // Enhanced Search Overlay
            if (_isSearchVisible)
              AnimatedOpacity(
                opacity: _isSearchVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: () => setState(() => _isSearchVisible = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      children: [
                        // Search Box Container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 8,
                            left: 16,
                            right: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Search TextField
                              TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search products...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[600],
                                    size: 24,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.grey[600],
                                      size: 24,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () => _isSearchVisible = false,
                                        ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              // Search Results Container (if there are results)
                              if (_searchQuery.isNotEmpty)
                                Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                        0.6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: displayedProducts?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      final product = displayedProducts![index];
                                      return ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: CachedImage(
                                              imageUrl: product.localImagePath,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          product.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Tk. ${product.price}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(
                                            () => _isSearchVisible = false,
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ProductDetailPage(
                                                        product: product,
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
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color:
                  _selectedIndex == 0 ? const Color(0xFFE5315D) : Colors.grey,
            ),
            label: 'Home',
          ),
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

// Product Card Widget
class ProductCard extends StatelessWidget {
  final ProductElement product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? const Color(0xFFE5315D) : Colors.grey,
                  ),
                  onPressed: onWishlistToggle,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price: Tk. ${product.price}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Model: ${product.model}',
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize enum names for display
extension StringCasingExtension on String {
  String capitalize() =>
      '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
}
