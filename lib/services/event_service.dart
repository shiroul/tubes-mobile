import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Service class for handling event-related operations
class EventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get event by ID
  static Future<Map<String, dynamic>?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  /// Get events stream for real-time updates
  static Stream<QuerySnapshot> getEventsStream() {
    return _firestore.collection('events').snapshots();
  }

  /// Get active events only
  static Stream<QuerySnapshot> getActiveEventsStream() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  /// Create new event (admin only)
  static Future<String> createEvent({
    required String type,
    required String details,
    required Map<String, dynamic> location,
    required Map<String, dynamic> requiredVolunteers,
    List<String>? media,
  }) async {
    try {
      final docRef = await _firestore.collection('events').add({
        'type': type,
        'details': details,
        'location': location,
        'requiredVolunteers': requiredVolunteers,
        'registeredVolunteers': <Map<String, dynamic>>[],
        'status': 'active',
        'reportedAt': FieldValue.serverTimestamp(),
        'createdBy': AuthService.currentUserId,
        'media': media ?? [],
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Resolve/Complete event and free up volunteers
  static Future<void> resolveEvent(String eventId) async {
    try {
      final batch = _firestore.batch();

      // Step 1: Update event status to completed
      batch.update(_firestore.collection('events').doc(eventId), {
        'status': 'completed',
        'resolvedAt': FieldValue.serverTimestamp(),
      });

      // Step 2: Find all volunteer registrations for this event
      final volunteerRegistrations = await _firestore
          .collection('volunteer_registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      // Step 3: Update volunteer availability and delete registrations
      for (final registration in volunteerRegistrations.docs) {
        final registrationData = registration.data();
        final userId = registrationData['userId'];

        if (userId != null) {
          // Update user's availability back to 'available'
          final userRef = _firestore.collection('users').doc(userId);
          batch.update(userRef, {
            'availability': 'available',
            'currentEventId': FieldValue.delete(),
            'currentRole': FieldValue.delete(),
          });
        }

        // Delete the volunteer registration record
        batch.delete(registration.reference);
      }

      // Execute all updates and deletions in a batch
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to resolve event: $e');
    }
  }

  /// Check if event exists and is active
  static Future<bool> isEventActive(String eventId) async {
    try {
      final event = await getEventById(eventId);
      return event != null && event['status'] == 'active';
    } catch (e) {
      return false;
    }
  }

  /// Get event statistics
  static Future<Map<String, int>> getEventStatistics() async {
    try {
      final eventsSnapshot = await _firestore.collection('events').get();
      
      int total = eventsSnapshot.docs.length;
      int active = 0;
      int completed = 0;

      for (final doc in eventsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'];
        
        if (status == 'active') {
          active++;
        } else if (status == 'completed') {
          completed++;
        }
      }

      return {
        'total': total,
        'active': active,
        'completed': completed,
      };
    } catch (e) {
      throw Exception('Failed to get event statistics: $e');
    }
  }

  /// Get registered volunteers count for an event
  static Future<int> getRegisteredVolunteersCount(String eventId) async {
    try {
      final registrations = await _firestore
          .collection('volunteer_registrations')
          .where('eventId', isEqualTo: eventId)
          .get();
      
      return registrations.docs.length;
    } catch (e) {
      throw Exception('Failed to get volunteers count: $e');
    }
  }

  /// Get remaining spots for each role in an event
  static Future<Map<String, int>> getRemainingSpots(String eventId) async {
    try {
      final event = await getEventById(eventId);
      if (event == null) return {};

      final requiredVolunteers = event['requiredVolunteers'] as Map<String, dynamic>? ?? {};
      final registeredVolunteers = event['registeredVolunteers'] as List<dynamic>? ?? [];

      final remainingSpots = <String, int>{};
      final registeredCounts = <String, int>{};

      // Count registered volunteers by role
      for (var volunteer in registeredVolunteers) {
        final role = volunteer['role'] as String?;
        if (role != null) {
          registeredCounts[role] = (registeredCounts[role] ?? 0) + 1;
        }
      }

      // Calculate remaining spots
      for (var role in requiredVolunteers.keys) {
        final required = requiredVolunteers[role] as int;
        final registered = registeredCounts[role] ?? 0;
        remainingSpots[role] = (required - registered).clamp(0, required);
      }

      return remainingSpots;
    } catch (e) {
      throw Exception('Failed to calculate remaining spots: $e');
    }
  }
}
