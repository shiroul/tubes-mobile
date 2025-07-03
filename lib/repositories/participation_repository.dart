import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipationData {
  final String eventId;
  final String eventTitle;
  final String eventLocation;
  final String selectedRole;
  final String status;
  final Timestamp registeredAt;
  final Timestamp? eventDate;

  ParticipationData({
    required this.eventId,
    required this.eventTitle,
    required this.eventLocation,
    required this.selectedRole,
    required this.status,
    required this.registeredAt,
    this.eventDate,
  });
}

class ParticipationRepository {
  final _registrationCollection = FirebaseFirestore.instance.collection('volunteer_registrations');
  final _eventCollection = FirebaseFirestore.instance.collection('events');

  Stream<ParticipationData?> getCurrentUserParticipation(String userId) {
    return _registrationCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      // Get the most recent registration manually (to avoid index requirement)
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = a.data()['registeredAt'] as Timestamp?;
        final bTime = b.data()['registeredAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime); // descending order
      });

      final registrationData = docs.first.data();
      final eventId = registrationData['eventId'];
      
      // Ensure eventId is a string
      if (eventId == null || eventId is! String) {
        return null;
      }
      
      // Fetch event details
      try {
        final eventDoc = await _eventCollection.doc(eventId).get();
        if (!eventDoc.exists) {
          // Return participation data with fallback values
          return ParticipationData(
            eventId: eventId,
            eventTitle: 'Event Tidak Ditemukan',
            eventLocation: 'Lokasi Tidak Diketahui',
            selectedRole: (registrationData['selectedRole'] ?? 'Relawan').toString(),
            status: (registrationData['status'] ?? 'pending').toString(),
            registeredAt: registrationData['registeredAt'] as Timestamp? ?? Timestamp.now(),
            eventDate: null,
          );
        }
        
        final eventData = eventDoc.data();
        
        if (eventData == null) {
          return ParticipationData(
            eventId: eventId,
            eventTitle: 'Data Event Kosong',
            eventLocation: 'Lokasi Tidak Diketahui',
            selectedRole: (registrationData['selectedRole'] ?? 'Relawan').toString(),
            status: (registrationData['status'] ?? 'pending').toString(),
            registeredAt: registrationData['registeredAt'] as Timestamp? ?? Timestamp.now(),
            eventDate: null,
          );
        }
        
        return ParticipationData(
          eventId: eventId,
          eventTitle: (eventData['title'] ?? eventData['type'] ?? eventData['name'] ?? 'Event Tidak Diketahui').toString(),
          eventLocation: _getLocationString(eventData),
          selectedRole: (registrationData['selectedRole'] ?? 'Relawan').toString(),
          status: (registrationData['status'] ?? 'pending').toString(),
          registeredAt: registrationData['registeredAt'] as Timestamp? ?? Timestamp.now(),
          eventDate: eventData['date'] as Timestamp? ?? eventData['reportedAt'] as Timestamp?,
        );
      } catch (e) {
        // Return participation data with fallback values instead of null
        return ParticipationData(
          eventId: eventId,
          eventTitle: 'Error Memuat Event',
          eventLocation: 'Lokasi Tidak Diketahui',
          selectedRole: (registrationData['selectedRole'] ?? 'Relawan').toString(),
          status: (registrationData['status'] ?? 'pending').toString(),
          registeredAt: registrationData['registeredAt'] as Timestamp? ?? Timestamp.now(),
          eventDate: null,
        );
      }
    });
  }

  String _getLocationString(Map<String, dynamic> eventData) {
    // Handle nested location structure like { location: { city: "...", province: "..." } }
    if (eventData['location'] is Map) {
      final location = eventData['location'] as Map<String, dynamic>;
      final city = location['city']?.toString() ?? '';
      final province = location['province']?.toString() ?? '';
      if (city.isNotEmpty && province.isNotEmpty) {
        return '$city, $province';
      } else if (city.isNotEmpty) {
        return city;
      } else if (province.isNotEmpty) {
        return province;
      }
    }
    
    // Handle direct location string
    if (eventData['location'] is String) {
      return eventData['location'].toString();
    }
    
    // Handle city and province as direct fields
    final city = eventData['city']?.toString() ?? '';
    final province = eventData['province']?.toString() ?? '';
    if (city.isNotEmpty && province.isNotEmpty) {
      return '$city, $province';
    } else if (city.isNotEmpty) {
      return city;
    } else if (province.isNotEmpty) {
      return province;
    }
    
    return 'Lokasi Tidak Diketahui';
  }

  Stream<List<Map<String, dynamic>>> participationsByUser(String userId) {
    return _registrationCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addParticipation(Map<String, dynamic> data) async {
    await _registrationCollection.add(data);
  }

  Future<void> updateParticipation(String id, Map<String, dynamic> data) async {
    await _registrationCollection.doc(id).update(data);
  }

  Future<void> deleteParticipation(String id) async {
    await _registrationCollection.doc(id).delete();
  }
}
