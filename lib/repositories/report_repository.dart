import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportRepository {
  final _collection = FirebaseFirestore.instance.collection('reports');

  Stream<List<ReportModel>> reportsByUser(String uid) {
    return _collection
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addReport(ReportModel report) async {
    await _collection.add(report.toMap());
  }

  Future<void> updateReport(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).update(data);
  }

  Future<void> deleteReport(String id) async {
    await _collection.doc(id).delete();
  }
}
