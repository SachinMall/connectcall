import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    final lastSeenTimestamp = map['lastSeen'];
    return AppUser(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      isOnline: map['isOnline'] as bool? ?? false,
      lastSeen: lastSeenTimestamp is Timestamp ? lastSeenTimestamp.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(lastSeen!),
    };
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
