import 'package:flutter/material.dart';
import '../app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset('assets/icon/appicon.png', width: 100, height: 100, fit: BoxFit.cover),
            ),
            const SizedBox(height: 24),
            const Text('Fliser', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text('Fliser Health Care', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
            const SizedBox(height: 64),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
