import 'dart:ui';

import 'package:flutter/material.dart';

class Blur extends StatelessWidget {
  const Blur({
    Key? key,
    required this.blur,
    required this.opacity,
    // required this.child,
  }) : super(key: key);

  final double blur;
  final double opacity;
  // final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // borderRadius: BorderRadius.circular(20), // Optional: Uncomment for rounded corners
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height,// Adjust the width as needed
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(opacity), // Use a specific color and apply opacity
            // Optional: Add border if needed
            // border: Border.all(
            //   width: 2.5,
            //   color: Colors.white.withOpacity(0.2),
            // ),
          ),
          // child: child, // Ensure the child widget is displayed inside the container
        ),
      ),
    );
  }
}
