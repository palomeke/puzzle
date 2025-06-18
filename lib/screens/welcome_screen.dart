import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: 'logo',
          child: Lottie.asset(
            'assets/animations/logo.json',
            width: 200,
            height: 200,
            repeat: false,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
