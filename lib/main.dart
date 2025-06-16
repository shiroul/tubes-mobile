import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'splash_screen.dart';
import 'register_screen1.dart';
import 'register_screen2.dart';
import 'sign_in_screen.dart';
import 'dashboard_screen.dart';
import 'other_screens.dart';
import 'user_profile_screen.dart';
import 'report_disaster_screen.dart';
import 'report_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LINA App',
      theme: ThemeData(primarySwatch: Colors.red),
      home: AuthGate(),
      routes: {
        '/signin': (context) => SignInScreen(),
        '/register1': (context) => RegisterScreen1(),
        '/register2': (context) => RegisterScreen2(),
        '/briefing': (context) => BriefingScreen(),
        '/confirmation': (context) => ConfirmationScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/profile': (context) => UserProfileScreen(),
        '/report': (context) => ReportDisasterScreen(),
        '/report_detail': (context) => const Placeholder(), // Placeholder, use onGenerateRoute for dynamic
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return DashboardScreen();
        }
        return SplashScreen();
      },
    );
  }
}
