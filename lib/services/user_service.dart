import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Service class for handling user-related operations
class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user by ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Update current user profile
  static Future<void> updateCurrentUserProfile(Map<String, dynamic> updates) async {
    final userId = AuthService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await updateUserProfile(userId: userId, updates: updates);
  }

  /// Get all users with role filter
  static Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }

  /// Get all volunteers
  static Future<List<Map<String, dynamic>>> getAllVolunteers() async {
    return await getUsersByRole('relawan');
  }

  /// Get available volunteers
  static Future<List<Map<String, dynamic>>> getAvailableVolunteers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'relawan')
          .where('availability', isEqualTo: 'available')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get available volunteers: $e');
    }
  }

  /// Get volunteers on active duty
  static Future<List<Map<String, dynamic>>> getActiveVolunteers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'relawan')
          .where('availability', isEqualTo: 'active duty')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get active volunteers: $e');
    }
  }

  /// Update user skills
  static Future<void> updateUserSkills(List<String> skills) async {
    final userId = AuthService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      await _firestore.collection('users').doc(userId).update({
        'skills': skills,
      });
    } catch (e) {
      throw Exception('Failed to update user skills: $e');
    }
  }

  /// Get user skills
  static Future<List<String>> getUserSkills([String? userId]) async {
    final targetUserId = userId ?? AuthService.currentUserId;
    if (targetUserId == null) throw Exception('User not logged in');

    try {
      final userData = await getUserById(targetUserId);
      final skills = userData?['skills'] as List<dynamic>? ?? [];
      return skills.map((skill) => skill.toString()).toList();
    } catch (e) {
      throw Exception('Failed to get user skills: $e');
    }
  }

  /// Check if user has specific skill
  static Future<bool> userHasSkill(String skill, [String? userId]) async {
    try {
      final userSkills = await getUserSkills(userId);
      return userSkills.contains(skill);
    } catch (e) {
      return false;
    }
  }

  /// Get user statistics for dashboard
  static Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      
      int totalUsers = usersSnapshot.docs.length;
      int totalVolunteers = 0;
      int totalAdmins = 0;
      int availableVolunteers = 0;
      int activeVolunteers = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'];
        
        if (role == 'admin') {
          totalAdmins++;
        } else if (role == 'relawan') {
          totalVolunteers++;
          
          final availability = data['availability'];
          if (availability == 'available') {
            availableVolunteers++;
          } else if (availability == 'active duty') {
            activeVolunteers++;
          }
        }
      }

      return {
        'totalUsers': totalUsers,
        'totalVolunteers': totalVolunteers,
        'totalAdmins': totalAdmins,
        'availableVolunteers': availableVolunteers,
        'activeVolunteers': activeVolunteers,
      };
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }

  /// Search users by name or email
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      // Note: Firestore doesn't support case-insensitive search directly
      // This is a simple implementation. For better search, consider using
      // Algolia or implementing proper search indexing
      
      final snapshot = await _firestore.collection('users').get();
      
      final results = <Map<String, dynamic>>[];
      final lowerQuery = query.toLowerCase();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = (data['name'] ?? '').toString().toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        
        if (name.contains(lowerQuery) || email.contains(lowerQuery)) {
          data['id'] = doc.id;
          results.add(data);
        }
      }
      
      return results;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get user's current event information
  static Future<Map<String, dynamic>?> getCurrentEventInfo([String? userId]) async {
    try {
      final targetUserId = userId ?? AuthService.currentUserId;
      if (targetUserId == null) return null;

      final userData = await getUserById(targetUserId);
      if (userData == null) return null;

      final currentEventId = userData['currentEventId'];
      if (currentEventId == null) return null;

      // Get event data
      final eventDoc = await _firestore.collection('events').doc(currentEventId).get();
      if (!eventDoc.exists) return null;

      final eventData = eventDoc.data()!;
      eventData['id'] = currentEventId;
      eventData['userRole'] = userData['currentRole'];

      return eventData;
    } catch (e) {
      throw Exception('Failed to get current event info: $e');
    }
  }

  /// Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  /// Get user by phone
  static Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by phone: $e');
    }
  }
}
