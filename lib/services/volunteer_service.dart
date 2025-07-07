import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'event_service.dart';

/// Service class for handling volunteer registration and management
class VolunteerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register volunteer for an event
  static Future<void> registerForEvent({
    required String eventId,
    required String selectedRole,
  }) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    final userData = await AuthService.getCurrentUserData();
    if (userData == null) throw Exception('User data not found');

    try {
      // Check if user has already registered for this event
      final existingRegistration = await _firestore
          .collection('volunteer_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (existingRegistration.docs.isNotEmpty) {
        throw Exception('Already registered for this event');
      }

      // Check if event is still active
      final isActive = await EventService.isEventActive(eventId);
      if (!isActive) {
        throw Exception('Event is no longer active');
      }

      // Check if role has available spots
      final remainingSpots = await EventService.getRemainingSpots(eventId);
      if ((remainingSpots[selectedRole] ?? 0) <= 0) {
        throw Exception('No available spots for role: $selectedRole');
      }

      // Check if user has required skill
      final userSkills = userData['skills'] as List<dynamic>? ?? [];
      final userSkillsSet = Set<String>.from(userSkills.map((skill) => skill.toString()));
      if (!userSkillsSet.contains(selectedRole)) {
        throw Exception('User does not have required skill: $selectedRole');
      }

      // Perform registration operations
      await _registerVolunteerTransaction(
        eventId: eventId,
        userId: currentUser.uid,
        userData: userData,
        selectedRole: selectedRole,
      );
    } catch (e) {
      throw Exception('Failed to register volunteer: $e');
    }
  }

  /// Internal method to handle volunteer registration transaction
  static Future<void> _registerVolunteerTransaction({
    required String eventId,
    required String userId,
    required Map<String, dynamic> userData,
    required String selectedRole,
  }) async {
    final batch = _firestore.batch();

    // Step 1: Create registration record
    final registrationRef = _firestore.collection('volunteer_registrations').doc();
    batch.set(registrationRef, {
      'eventId': eventId,
      'userId': userId,
      'userName': userData['name'] ?? 'Unknown',
      'userEmail': userData['email'] ?? 'Unknown',
      'selectedRole': selectedRole,
      'status': 'confirmed',
      'registeredAt': FieldValue.serverTimestamp(),
    });

    // Step 2: Update user status
    final userRef = _firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'availability': 'active duty',
      'currentEventId': eventId,
      'currentRole': selectedRole,
    });

    // Step 3: Update event document
    final eventRef = _firestore.collection('events').doc(eventId);
    final eventDoc = await eventRef.get();
    
    if (eventDoc.exists) {
      final eventData = eventDoc.data() as Map<String, dynamic>;
      final registeredVolunteers = List<Map<String, dynamic>>.from(
        eventData['registeredVolunteers'] ?? []
      );

      // Add user info to registered volunteers
      registeredVolunteers.add({
        'userId': userId,
        'userName': userData['name'] ?? 'Unknown',
        'userEmail': userData['email'] ?? 'Unknown',
        'role': selectedRole,
        'registeredAt': Timestamp.now(),
        'skills': userData['skills'] ?? [],
        'phone': userData['phone'] ?? '',
      });

      batch.update(eventRef, {
        'registeredVolunteers': registeredVolunteers,
      });
    }

    // Execute all operations
    await batch.commit();
  }

  /// Get volunteer registrations for a specific event
  static Future<List<Map<String, dynamic>>> getEventVolunteers(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('volunteer_registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get event volunteers: $e');
    }
  }

  /// Get volunteer registrations for current user
  static Future<List<Map<String, dynamic>>> getCurrentUserRegistrations() async {
    final userId = AuthService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      final snapshot = await _firestore
          .collection('volunteer_registrations')
          .where('userId', isEqualTo: userId)
          .get();

      final registrations = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Get event data
        final eventData = await EventService.getEventById(data['eventId']);
        if (eventData != null) {
          data['eventData'] = eventData;
        }
        
        registrations.add(data);
      }

      return registrations;
    } catch (e) {
      throw Exception('Failed to get user registrations: $e');
    }
  }

  /// Check if current user is registered for an event
  static Future<bool> isUserRegisteredForEvent(String eventId) async {
    final userId = AuthService.currentUserId;
    if (userId == null) return false;

    try {
      final snapshot = await _firestore
          .collection('volunteer_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get volunteer statistics
  static Future<Map<String, int>> getVolunteerStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      
      int totalRegistered = 0;
      int activeUsers = 0;
      int availableUsers = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'];
        
        if (role == 'relawan' || role == 'volunteer') {
          totalRegistered++;
          
          final availability = data['availability'];
          if (availability == 'active duty') {
            activeUsers++;
          } else if (availability == 'available') {
            availableUsers++;
          }
        }
      }

      return {
        'totalRegistered': totalRegistered,
        'activeUsers': activeUsers,
        'availableUsers': availableUsers,
      };
    } catch (e) {
      throw Exception('Failed to get volunteer statistics: $e');
    }
  }

  /// Cancel volunteer registration
  static Future<void> cancelRegistration(String eventId) async {
    final userId = AuthService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      final batch = _firestore.batch();

      // Find and delete registration
      final registrations = await _firestore
          .collection('volunteer_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in registrations.docs) {
        batch.delete(doc.reference);
      }

      // Update user availability
      await AuthService.clearUserEventInfo();

      // Remove from event's registered volunteers list
      final eventRef = _firestore.collection('events').doc(eventId);
      final eventDoc = await eventRef.get();
      
      if (eventDoc.exists) {
        final eventData = eventDoc.data() as Map<String, dynamic>;
        final registeredVolunteers = List<Map<String, dynamic>>.from(
          eventData['registeredVolunteers'] ?? []
        );

        // Remove user from registered volunteers
        registeredVolunteers.removeWhere((volunteer) => volunteer['userId'] == userId);

        batch.update(eventRef, {
          'registeredVolunteers': registeredVolunteers,
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cancel registration: $e');
    }
  }
}
