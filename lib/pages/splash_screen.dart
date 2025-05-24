import 'package:flutter/material.dart';
import '../main.dart'; // убедись, что путь к MainScreen правильный

class SplashScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const SplashScreen({
    Key? key,
    required this.isDark,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => MainScreen(
          isDark: widget.isDark,
          toggleTheme: widget.toggleTheme,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Tickit',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ),
    );
  }
}
