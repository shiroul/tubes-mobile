import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipationRepository {
  final _collection = FirebaseFirestore.instance.collection('participations');

  Stream<List<Map<String, dynamic>>> participationsByUser(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addParticipation(Map<String, dynamic> data) async {
    await _collection.add(data);
  }

  Future<void> updateParticipation(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).update(data);
  }

  Future<void> deleteParticipation(String id) async {
    await _collection.doc(id).delete();
  }
}
