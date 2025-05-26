import 'package:flutter/material.dart';
import 'package:ecommerce_app/homepage.dart';
import 'package:ecommerce_app/signup.dart';
import 'package:ecommerce_app/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ecommerce_app/dashboard.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/cart_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final cartModel = CartModel();
        // Initialize user data if user is logged in
        if (FirebaseAuth.instance.currentUser != null) {
          cartModel.initializeUserData();
        }
        return cartModel;
      },
      child: Myapp(),
    ),
  );
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Dashboard(), // Always start with Dashboard
    );
  }
}
