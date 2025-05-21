import 'package:flutter/material.dart';
import 'package:ecommerce_app/signup.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5315D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'asset/image/logo.png',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                child: Column(
                  children: [
                    const Text(
                      'Welcome to ShopSphere',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your World of Style, One Click Away',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 700),
                curve: Curves.fastOutSlowIn,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      createBottomToTopRoute(const SignUpPage()),
                    );
                  },
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Route createBottomToTopRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 700),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(opacity: fadeAnimation, child: child),
      );
    },
  );
}
