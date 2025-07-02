import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/disaster_event.dart';

class EventWithId {
  final String id;
  final DisasterEvent event;
  EventWithId(this.id, this.event);
}

class EventRepository {
  final _collection = FirebaseFirestore.instance.collection('events');

  Future<List<EventWithId>> getActiveEvents() async {
    final snapshot = await _collection.where('status', isEqualTo: 'active').get();
    return snapshot.docs.map((doc) => EventWithId(doc.id, DisasterEvent.fromMap(doc.data()))).toList();
  }

  Stream<List<EventWithId>> watchActiveEvents() {
    return _collection.where('status', isEqualTo: 'active').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => EventWithId(doc.id, DisasterEvent.fromMap(doc.data()))).toList(),
    );
  }
}
