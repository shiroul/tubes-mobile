import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserRepository {
  final _collection = FirebaseFirestore.instance.collection('users');

  Stream<UserProfile?> getUserProfile(String uid) {
    return _collection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(uid, doc.data()!);
    });
  }

  Future<UserProfile?> fetchUserProfile(String uid) async {
    final doc = await _collection.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(uid, doc.data()!);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _collection.doc(uid).update(data);
  }
}
