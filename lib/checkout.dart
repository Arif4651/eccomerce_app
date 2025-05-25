import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/cart_model.dart';
import 'package:ecommerce_app/services/user_data_service.dart';
import 'package:ecommerce_app/account.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  bool _isProcessing = false;
  final UserDataService _userDataService = UserDataService();

  Future<void> _processPayment(BuildContext context) async {
    setState(() => _isProcessing = true);

    try {
      final cart = Provider.of<CartModel>(context, listen: false);
      final totalAmount = cart.getTotalPriceFromMap();

      // Generate a unique transaction ID using timestamp
      final tranId = "TRX${DateTime.now().millisecondsSinceEpoch}";

      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          multi_card_name: "visa,master,bkash",
          currency: SSLCurrencyType.BDT,
          product_category: "Electronic Product",
          sdkType: SSLCSdkType.TESTBOX,
          store_id: "wrist6830197f2308c",
          store_passwd: "wrist6830197f2308c@ssl",
          total_amount: totalAmount,
          tran_id: tranId,
        ),
      );

      final response = await sslcommerz.payNow();

      if (mounted) {
        if (response.status == 'VALID') {
          // Payment successful - Save order history
          try {
            // Create a list of order items from the cart
            final List<Map<String, dynamic>> orderItems =
                cart.itemQuantitiesMap.entries.map((entry) {
                  final product = entry.key;
                  final quantity = entry.value;
                  return {
                    'productName': product.title,
                    'price': product.price,
                    'quantity': quantity,
                    'total': product.price * quantity,
                    'imageUrl': product.image, // Optional: include image URL
                  };
                }).toList();

            // Save order history to Firestore
            await _userDataService.saveUserOrderHistory(orderItems);
            print('Order history saved successfully');

            // Clear cart after successful payment and saving
            await cart.clearCart();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Payment completed and order saved!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Navigate to Account page to show order history
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AccountPage()),
              (route) => false,
            );
          } catch (e) {
            print('Error saving order history: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment successful but failed to save order: $e',
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (response.status == 'FAILED') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Payment failed. Please try again.'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (response.status == 'CLOSED') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Payment window closed.'),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
                  child: Text('Error processing payment: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final totalAmount = cart.getTotalPriceFromMap();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '৳${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isProcessing ? null : () => _processPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5315D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Proceed to Payment',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
