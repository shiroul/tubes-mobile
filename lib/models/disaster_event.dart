import 'package:cloud_firestore/cloud_firestore.dart';

class DisasterEvent {
  final String type;
  final String details;
  final GeoPoint coordinates;
  final String city;
  final String province;
  final Map<String, int> requiredVolunteers;
  final String severityLevel;
  final String status;
  final Timestamp timestamp;

  const DisasterEvent({
    required this.type,
    required this.details,
    required this.coordinates,
    required this.city,
    required this.province,
    required this.requiredVolunteers,
    this.severityLevel = 'sedang',
    this.status = 'active',
    required this.timestamp,
  });

  factory DisasterEvent.fromMap(Map<String, dynamic> map) {
    return DisasterEvent(
      type: map['type'] ?? '-',
      details: map['details'] ?? '-',
      coordinates: map['location']?['coordinates'] ?? GeoPoint(0, 0),
      city: map['location']?['city'] ?? '-',
      province: map['location']?['province'] ?? '-',
      requiredVolunteers: Map<String, int>.from(map['requiredVolunteers'] ?? {}),
      severityLevel: map['severityLevel'] ?? 'sedang',
      status: map['status'] ?? 'active',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'details': details,
      'location': {
        'coordinates': coordinates,
        'city': city,
        'province': province,
      },
      'requiredVolunteers': requiredVolunteers,
      'severityLevel': severityLevel,
      'status': status,
      'timestamp': timestamp,
    };
  }

  DisasterEvent copyWith({
    String? type,
    String? details,
    GeoPoint? coordinates,
    String? city,
    String? province,
    Map<String, int>? requiredVolunteers,
    String? severityLevel,
    String? status,
    Timestamp? timestamp,
  }) {
    return DisasterEvent(
      type: type ?? this.type,
      details: details ?? this.details,
      coordinates: coordinates ?? this.coordinates,
      city: city ?? this.city,
      province: province ?? this.province,
      requiredVolunteers: requiredVolunteers ?? this.requiredVolunteers,
      severityLevel: severityLevel ?? this.severityLevel,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisasterEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          details == other.details &&
          coordinates == other.coordinates &&
          city == other.city &&
          province == other.province &&
          requiredVolunteers == other.requiredVolunteers &&
          severityLevel == other.severityLevel &&
          status == other.status &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(
        type,
        details,
        coordinates,
        city,
        province,
        requiredVolunteers,
        severityLevel,
        status,
        timestamp,
      );
}
