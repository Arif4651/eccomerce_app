import 'package:flutter/material.dart';
import 'package:ecommerce_app/homepage.dart';
import 'package:ecommerce_app/signup.dart';
import 'package:ecommerce_app/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ecommerce_app/dashboard.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/cart_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(create: (context) => CartModel(), child: Myapp()),
  );
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Dashboard());
  }
}
