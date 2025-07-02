import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String uid;
  final String type;
  final String details;
  final GeoPoint coordinates;
  final String city;
  final String province;
  final String status;
  final List<String> media;
  final Timestamp? timestamp;

  const ReportModel({
    required this.id,
    required this.uid,
    required this.type,
    required this.details,
    required this.coordinates,
    required this.city,
    required this.province,
    this.status = 'pending',
    this.media = const [],
    this.timestamp,
  });

  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id,
      uid: map['uid'] ?? '',
      type: map['type'] ?? '-',
      details: map['details'] ?? '-',
      coordinates: map['location']?['coordinates'] ?? GeoPoint(0, 0),
      city: map['location']?['city'] ?? '-',
      province: map['location']?['province'] ?? '-',
      status: map['status'] ?? 'pending',
      media: (map['media'] as List?)?.whereType<String>().toList() ?? [],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'type': type,
      'details': details,
      'location': {
        'coordinates': coordinates,
        'city': city,
        'province': province,
      },
      'status': status,
      'media': media,
      'timestamp': timestamp,
    };
  }

  ReportModel copyWith({
    String? id,
    String? uid,
    String? type,
    String? details,
    GeoPoint? coordinates,
    String? city,
    String? province,
    String? status,
    List<String>? media,
    Timestamp? timestamp,
  }) {
    return ReportModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      details: details ?? this.details,
      coordinates: coordinates ?? this.coordinates,
      city: city ?? this.city,
      province: province ?? this.province,
      status: status ?? this.status,
      media: media ?? this.media,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uid == other.uid &&
          type == other.type &&
          details == other.details &&
          coordinates == other.coordinates &&
          city == other.city &&
          province == other.province &&
          status == other.status &&
          media == other.media &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(
        id,
        uid,
        type,
        details,
        coordinates,
        city,
        province,
        status,
        media,
        timestamp,
      );
}
