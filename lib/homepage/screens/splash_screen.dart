import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final Widget nextScreen;
  const SplashScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Colors.white,
      splashIconSize: 250,
      duration: 1300,
      splash: Image.asset(
        "assets/images/logo.png",
        fit: BoxFit.contain,
      ),
      nextScreen: nextScreen,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.bottomToTop,
    );
  }
}