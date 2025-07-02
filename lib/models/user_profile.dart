class UserProfile {
  final String uid;
  final String name;
  final String phone;
  final List<String> skills;
  final String? profileImageUrl;
  final String? emergencyNumber;
  final String availability;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.skills,
    this.profileImageUrl,
    this.emergencyNumber,
    this.availability = 'available',
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '-',
      phone: map['phone'] ?? '-',
      skills: (map['skills'] as List?)?.cast<String>() ?? [],
      profileImageUrl: map['profileImageUrl'],
      emergencyNumber: map['emergencyNumber'],
      availability: map['availability'] ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'skills': skills,
      'profileImageUrl': profileImageUrl,
      'emergencyNumber': emergencyNumber,
      'availability': availability,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? phone,
    List<String>? skills,
    String? profileImageUrl,
    String? emergencyNumber,
    String? availability,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      skills: skills ?? this.skills,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
      availability: availability ?? this.availability,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          name == other.name &&
          phone == other.phone &&
          skills == other.skills &&
          profileImageUrl == other.profileImageUrl &&
          emergencyNumber == other.emergencyNumber &&
          availability == other.availability;

  @override
  int get hashCode => Object.hash(
        uid,
        name,
        phone,
        skills,
        profileImageUrl,
        emergencyNumber,
        availability,
      );
}
