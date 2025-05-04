// lib/models/user.dart
enum UserRole {
  basic_user,
  admin
}

class User {
  final int id;
  final String email;
  final String fullName;
  final String? iban;
  final UserRole role;
  final String? token;  // optionnel car pas dans la DB mais utile pour l'auth

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.iban,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    email: json['email'] as String,
    fullName: json['full_name'] as String,
    iban: json['iban'] as String?,
    role: json['role'] == 'admin' ? UserRole.admin : UserRole.basic_user,
    token: json['token'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'iban': iban,
    'role': role == UserRole.admin ? 'admin' : 'basic_user',
    if (token != null) 'token': token,
  };

  // Méthodes utiles
  bool get isAdmin => role == UserRole.admin;

  @override
  String toString() => fullName;  // Utile pour l'affichage
}