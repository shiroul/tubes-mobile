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
import 'screens/admin/report_acceptance_confirmation_screen.dart';
import 'screens/volunteers/volunteer_registration_screen.dart';
import 'screens/volunteers/volunteers_list_screen.dart';
import 'services/services.dart';
import 'core/constants/app_theme.dart';

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
      theme: AppTheme.lightTheme,
      home: AuthGate(),
      routes: {
        '/signin': (context) => SignInScreen(),
        '/register': (context) => RegisterScreen(),
        '/briefing': (context) => BriefingScreen(),
        '/confirmation': (context) => ConfirmationScreen.registration(),
        '/confirmation_report': (context) => ConfirmationScreen.reportSubmitted(),
        '/confirmation_event': (context) => ConfirmationScreen.eventCreated(),
        '/confirmation_disaster_resolved': (context) => ConfirmationScreen.disasterResolved(),
        '/confirmation_report_accepted': (context) => ConfirmationScreen.reportAccepted(),
        '/confirmation_volunteer_registered': (context) => ConfirmationScreen.volunteerRegistered(),
        '/dashboard': (context) => DashboardScreen(),
        '/profile': (context) => UserProfileScreen(),
        '/report': (context) => CreateReportScreen(),
        '/all-events': (context) => AllEventsScreen(),
        '/admin_all_reports': (context) => AllReportsScreen(),
        '/admin_create_event': (context) => CreateEventScreen(),
        '/my_reports': (context) => MyReportsScreen(),
        '/volunteers': (context) => VolunteersListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/report_acceptance_confirmation') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ReportAcceptanceConfirmationScreen(
              reportId: args['reportId'],
              eventData: args['eventData'],
              volunteerSummary: args['volunteerSummary'],
              severity: args['severity'],
            ),
          );
        }
        if (settings.name == '/volunteer_registration') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => VolunteerRegistrationScreen(
              eventId: args['eventId'],
            ),
          );
        }
        return null;
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
