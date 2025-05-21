import 'package:flutter/material.dart';
import 'package:ecommerce_app/model/model.dart'; // Import ProductElement
import 'package:provider/provider.dart'; // Import provider
import 'package:ecommerce_app/cart_model.dart'; // Import CartModel

class ProductDetailPage extends StatelessWidget {
  final ProductElement product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title), // Product title in AppBar
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Image.network(
              product.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300, // Adjust height as needed
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    // Handle broken images
                    height: 300,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title
                  Text(
                    product.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Product Price
                  Text(
                    'Price: Tk. ${product.price}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product Model
                  if (product.model.isNotEmpty)
                    Text(
                      'Model: ${product.model}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  const SizedBox(height: 8),
                  // Product Color (if available)
                  if (product.color != null && product.color!.isNotEmpty)
                    Text(
                      'Color: ${product.color}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  const SizedBox(height: 16),
                  // Product Description
                  Text(product.description, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  // Add to Cart Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Access CartModel using Provider and add the item
                        Provider.of<CartModel>(
                          context,
                          listen: false,
                        ).addItemWithQuantity(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${product.title} to cart!',
                              style: TextStyle(color: Colors.white),
                            ),
                            duration: Duration(seconds: 2),
                            backgroundColor: Color(0xFFE5315D),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                        // Optional: Navigate back after adding to cart
                        // Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE5315D), // Button color
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        textStyle: TextStyle(fontSize: 18),
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
    );
  }
}
