import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/833/833472.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              '❤️ LINA',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Text('Selamat datang', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/signin'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
