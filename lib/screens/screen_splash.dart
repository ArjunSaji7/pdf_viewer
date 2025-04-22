import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdf_viewer/screens/screen_home.dart';
import 'package:pdf_viewer/screens/screen_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Start fade-in animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Check login status after delay
    Timer(const Duration(seconds: 3), () {
      checkUserLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Logo Image
          // Center(
          //   child: Container(
          //     height: 300,
          //     width: 300,
          //     child: Image.asset(
          //       'assets/images/smec logo.png',
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),

          // Welcome Text
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                duration: const Duration(seconds: 2),
                opacity: _opacity,
                child: Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.blueAccent.withOpacity(0.8),
                        offset: Offset(2, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void checkUserLoginStatus() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      goToScreen(ScreenHome());
    } else {
      goToScreen(ScreenLogin());
    }
  }

  void goToScreen(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
