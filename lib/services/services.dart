/// Export all service classes for easy importing
/// 
/// Usage:
/// ```dart
/// import 'package:app/services/services.dart';
/// 
/// // Now you can use:
/// await AuthService.getCurrentUserData();
/// await EventService.getEventById(eventId);
/// await VolunteerService.registerForEvent(...);
/// ```

export 'auth_service.dart';
export 'event_service.dart';
export 'volunteer_service.dart';
export 'user_service.dart';
export 'report_service.dart';
