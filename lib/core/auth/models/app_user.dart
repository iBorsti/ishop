import 'dart:convert';

enum UserRole { buyer, seller, delivery, fleet, admin }

String _roleToString(UserRole r) => r.name;

UserRole _roleFromString(String s) {
  switch (s) {
    case 'seller':
      return UserRole.seller;
    case 'delivery':
      return UserRole.delivery;
    case 'fleet':
      return UserRole.fleet;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.buyer;
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    role: _roleFromString(json['role'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': _roleToString(role),
  };

  String toRawJson() => json.encode(toJson());

  factory AppUser.fromRawJson(String raw) => AppUser.fromJson(json.decode(raw));
}
