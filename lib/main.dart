import 'package:flutter/material.dart';
import 'package:ecommerce_app/homepage.dart';
import 'package:ecommerce_app/signup.dart';
import 'package:ecommerce_app/login.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async
{
     WidgetsFlutterBinding.ensureInitialized();
    await  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(Myapp());
}
class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      home: HomePage(),


    );
  }
}
