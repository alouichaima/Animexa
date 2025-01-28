import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalUser {
  final String role;
  final String id;
  final String username;
  final String email;
  final String region;
  final String tel;
  final String? profileImageUrl;

  LocalUser({
    required this.role,
    required this.id,
    required this.username,
    required this.email,
    required this.region,
    required this.tel,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'id': id,
      'username': username,
      'email': email,
      'region': region,
      'tel': tel,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      role: map['role'] as String? ?? '',
      id: map['id'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      region: map['region'] as String? ?? '',
      tel: map['tel'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }

  
  factory LocalUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LocalUser(
      role: data['role'] ?? '',
      id: doc.id, 
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      region: data['region'] ?? '',
      tel: data['tel'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory LocalUser.fromJson(String source) =>
      LocalUser.fromMap(json.decode(source) as Map<String, dynamic>);

  
  LocalUser copyWith({
    String? role,
    String? id,
    String? username,
    String? email,
    String? region,
    String? tel,
    String? profileImageUrl,
  }) {
    return LocalUser(
      role: role ?? this.role,
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      region: region ?? this.region,
      tel: tel ?? this.tel,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
