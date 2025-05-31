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
  final String? token; // utile pour l'auth (optionnel)

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

  bool get isAdmin => role == UserRole.admin;

  @override
  String toString() => fullName;

  // -----------------------
  //     VALIDATEURS
  // -----------------------

  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    const pat = r'^[\w\.\-]+@([\w\-]+\.)+[\w]{2,4}$';
    if (!RegExp(pat).hasMatch(v.trim())) return 'Invalid email';
    return null;
  }

  static String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (v.trim().length < 3) return 'Name too short';
    return null;
  }

  static String? validateIban(String? v) {
    if (v == null || v.isEmpty) return null; // facultatif
    return RegExp(r'^BE\d{2}(?: \d{4}){3}$').hasMatch(v)
        ? null
        : 'Invalid format';
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (v.length < 8) return 'Minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Need A-Z';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Need a-z';
    if (!RegExp(r'\d').hasMatch(v)) return 'Need 0-9';
    if (!RegExp(r'[!@#\$%^&*(),.?\":{}|<>]').hasMatch(v)) return 'Need symbol';
    return null;
  }

  /// Pour le validator du champ de confirmation (à utiliser dans SignupScreen)
  static String? validateConfirmPwd(String? v, String pwd) {
    if (v == null || v.isEmpty) return 'Required';
    return v == pwd ? null : 'Mismatch';
  }
}
