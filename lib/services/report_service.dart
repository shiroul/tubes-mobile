import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Service class for handling report-related operations
class ReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all reports
  static Stream<QuerySnapshot> getReportsStream() {
    return _firestore.collection('reports').orderBy('timestamp', descending: true).snapshots();
  }

  /// Get reports by status
  static Stream<QuerySnapshot> getReportsByStatus(String status) {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: status)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get pending reports (for admin)
  static Stream<QuerySnapshot> getPendingReportsStream() {
    return getReportsByStatus('pending');
  }

  /// Get reports by current user
  static Stream<QuerySnapshot> getCurrentUserReportsStream() {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      // Return empty stream if no user
      return const Stream.empty();
    }
    
    return _firestore
        .collection('reports')
        .where('reporterId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Create new report
  static Future<String> createReport({
    required String disasterType,
    required String description,
    required Map<String, dynamic> location,
    List<String>? media,
    Map<String, dynamic>? additionalData,
  }) async {
    final userId = AuthService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final userData = await AuthService.getCurrentUserData();
    if (userData == null) throw Exception('User data not found');

    try {
      final docRef = await _firestore.collection('reports').add({
        'disasterType': disasterType,
        'description': description,
        'location': location,
        'media': media ?? [],
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'reporterId': userId,
        'reporterName': userData['name'] ?? 'Unknown',
        'reporterEmail': userData['email'] ?? 'Unknown',
        'reviewedBy': null,
        'reviewedAt': null,
        'eventId': null, // Will be set if report is accepted and event is created
        ...?additionalData,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  /// Update report status (admin only)
  static Future<void> updateReportStatus({
    required String reportId,
    required String status,
    String? eventId,
    String? rejectionReason,
  }) async {
    final adminId = AuthService.currentUserId;
    if (adminId == null) throw Exception('Admin not logged in');

    // Verify admin role
    final isAdmin = await AuthService.isCurrentUserAdmin();
    if (!isAdmin) throw Exception('Insufficient permissions');

    try {
      final updateData = <String, dynamic>{
        'status': status,
        'reviewedBy': adminId,
        'reviewedAt': FieldValue.serverTimestamp(),
      };

      if (eventId != null) {
        updateData['eventId'] = eventId;
      }

      if (rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }

      await _firestore.collection('reports').doc(reportId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  /// Accept report and create event
  static Future<String> acceptReportAndCreateEvent({
    required String reportId,
    required Map<String, dynamic> requiredVolunteers,
    String? additionalDetails,
  }) async {
    final adminId = AuthService.currentUserId;
    if (adminId == null) throw Exception('Admin not logged in');

    // Verify admin role
    final isAdmin = await AuthService.isCurrentUserAdmin();
    if (!isAdmin) throw Exception('Insufficient permissions');

    try {
      // Get report data
      final reportDoc = await _firestore.collection('reports').doc(reportId).get();
      if (!reportDoc.exists) throw Exception('Report not found');

      final reportData = reportDoc.data()!;
      
      // Create event from report
      final eventRef = await _firestore.collection('events').add({
        'type': reportData['disasterType'],
        'details': additionalDetails ?? reportData['description'],
        'location': reportData['location'],
        'requiredVolunteers': requiredVolunteers,
        'registeredVolunteers': <Map<String, dynamic>>[],
        'status': 'active',
        'reportedAt': FieldValue.serverTimestamp(),
        'createdBy': adminId,
        'media': reportData['media'] ?? [],
        'originalReportId': reportId,
      });

      // Update report status with event ID
      await updateReportStatus(
        reportId: reportId,
        status: 'accepted',
        eventId: eventRef.id,
      );

      return eventRef.id;
    } catch (e) {
      throw Exception('Failed to accept report and create event: $e');
    }
  }

  /// Reject report
  static Future<void> rejectReport({
    required String reportId,
    required String rejectionReason,
  }) async {
    await updateReportStatus(
      reportId: reportId,
      status: 'rejected',
      rejectionReason: rejectionReason,
    );
  }

  /// Get report by ID
  static Future<Map<String, dynamic>?> getReportById(String reportId) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  /// Get report statistics
  static Future<Map<String, int>> getReportStatistics() async {
    try {
      final reportsSnapshot = await _firestore.collection('reports').get();
      
      int total = reportsSnapshot.docs.length;
      int pending = 0;
      int accepted = 0;
      int rejected = 0;

      for (final doc in reportsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'];
        
        switch (status) {
          case 'pending':
            pending++;
            break;
          case 'accepted':
            accepted++;
            break;
          case 'rejected':
            rejected++;
            break;
        }
      }

      return {
        'total': total,
        'pending': pending,
        'accepted': accepted,
        'rejected': rejected,
      };
    } catch (e) {
      throw Exception('Failed to get report statistics: $e');
    }
  }

  /// Delete report (soft delete by updating status)
  static Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': AuthService.currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  /// Search reports by disaster type or location
  static Future<List<Map<String, dynamic>>> searchReports(String query) async {
    try {
      final snapshot = await _firestore.collection('reports').get();
      
      final results = <Map<String, dynamic>>[];
      final lowerQuery = query.toLowerCase();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final disasterType = (data['disasterType'] ?? '').toString().toLowerCase();
        final description = (data['description'] ?? '').toString().toLowerCase();
        final location = data['location'] as Map<String, dynamic>? ?? {};
        final city = (location['city'] ?? '').toString().toLowerCase();
        final province = (location['province'] ?? '').toString().toLowerCase();
        
        if (disasterType.contains(lowerQuery) || 
            description.contains(lowerQuery) ||
            city.contains(lowerQuery) ||
            province.contains(lowerQuery)) {
          data['id'] = doc.id;
          results.add(data);
        }
      }
      
      return results;
    } catch (e) {
      throw Exception('Failed to search reports: $e');
    }
  }
}
