import 'package:flutter/material.dart';
import 'package:ecommerce_app/dashboard.dart'; // Import Dashboard
import 'package:ecommerce_app/cartlist.dart'; // Import CartListPage
import 'package:ecommerce_app/whishlist.dart'; // Import WishlistPage

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _selectedIndex = 3; // Set initial index for Account page

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
      appBar: AppBar(title: const Text('Account')), // Added AppBar for context
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section (Placeholder)
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50, // Adjust size as needed
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey[600],
                    ), // Placeholder icon
                  ),
                  const SizedBox(height: 8.0),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement logic to add/change profile picture
                    },
                    child: const Text('Change Profile Picture'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            // Profile Information Section (Placeholder)
            const Text(
              'Profile Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: User Name'), // TODO: Fetch actual name
                    const SizedBox(height: 8.0),
                    Text(
                      'Email: user.email@example.com',
                    ), // TODO: Fetch actual email
                    // Add more profile details here
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            // Order History Section (Placeholder)
            const Text(
              'Order History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              // Use Expanded to allow ListView.builder to take remaining space
              child: ListView.builder(
                // TODO: Fetch and display actual order history
                itemCount: 5, // Placeholder count
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.shopping_bag_outlined),
                    title: Text(
                      'Order #12345 - Date',
                    ), // Placeholder order details
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to order detail page
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
