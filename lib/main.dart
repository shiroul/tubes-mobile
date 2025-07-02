import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/briefing_screen.dart';
import 'screens/dashboard_screen.dart';
import 'widgets/confirmation_screen.dart';
import 'screens/profile/user_profile_screen.dart';
import 'screens/events/all_events_screen.dart';
import 'screens/reports/create_report_screen.dart';
import 'screens/reports/my_reports_screen.dart';
import 'screens/admin/create_event_screen.dart';
import 'screens/admin/all_reports_screen.dart';

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
        '/register': (context) => RegisterScreen(),
        '/briefing': (context) => BriefingScreen(),
        '/confirmation': (context) => ConfirmationScreen.registration(),
        '/confirmation_report': (context) => ConfirmationScreen.reportSubmitted(),
        '/confirmation_event': (context) => ConfirmationScreen.eventCreated(),
        '/confirmation_disaster_resolved': (context) => ConfirmationScreen.disasterResolved(),
        '/dashboard': (context) => DashboardScreen(),
        '/profile': (context) => UserProfileScreen(),
        '/report': (context) => CreateReportScreen(),
        '/all-events': (context) => AllEventsScreen(),
        '/admin_all_reports': (context) => AllReportsScreen(),
        '/report_detail': (context) => const Placeholder(), // Placeholder, use onGenerateRoute for dynamic
        '/admin_create_event': (context) => CreateEventScreen(),
        '/my_reports': (context) => MyReportsScreen(),
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
