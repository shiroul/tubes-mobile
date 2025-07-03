import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  Future<String?> _getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return (doc.data() as Map<String, dynamic>)['role'] as String?;
        }
      }
    } catch (e) {
      print('Error getting user role: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red[600],
      unselectedItemColor: Colors.grey[600],
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) async {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/dashboard');
            break;
          case 1:
            // Role-based navigation for second button
            final role = await _getUserRole();
            if (role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin_create_event');
            } else {
              Navigator.pushReplacementNamed(context, '/report');
            }
            break;
          case 2:
            // All events screen for both roles
            Navigator.pushReplacementNamed(context, '/all-events');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/volunteers');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Tambah',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warning_amber_rounded),
          label: 'Bencana',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Relawan',
        ),
      ],
    );
  }
}
