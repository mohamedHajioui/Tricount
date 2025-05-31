import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'api_client.dart';
import 'package:prbd_2425_a07/core/services/api_client.dart';
import 'package:prbd_2425_a07/core/tools/params.dart';
import 'package:prbd_2425_a07/models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class AuthService {  // Ajoute la classe !
  Future<User> login(String email, String password) async {
    final res = await ApiClient.post(
      'login',
      anonymous: true,
      body: jsonEncode({
        'email' : email,
        'password' : password
      }),
    );

    if(res.statusCode != 200){
      throw Exception('Login failed (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);

    final Map<String, dynamic> row = decoded is List
        ? (decoded.first as Map<String, dynamic>)
        : (decoded as Map<String, dynamic>);

    final token = row['token'] as String;

    // Décoder le token pour obtenir les informations de l'utilisateur
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    

    Params.setValue('token', token);
    

    return User(
        id: decodedToken['user_id'] as int,
        email: decodedToken['sub'] as String,  // 'sub' contient l'email
        fullName: email.split('@')[0],  
        role: decodedToken['role'] == 'admin' ? UserRole.admin : UserRole.basic_user,
        token: token
    );
  }

  Future<User> signup(String email, String fullName, String iban, String password) async {
    final ibanValue = iban.isEmpty ? null : iban;
    final res = await ApiClient.post(
      'signup',
      anonymous: true,
      body: jsonEncode({
        'email': email,
        'full_name': fullName,
        'iban': ibanValue,
        'password': password,
      }),
    );
    debugPrint('HTTP ${res.statusCode}  ${res.body}');

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message']);
    }

    // On récupère le token du backend
    final row = jsonDecode(res.body) as Map<String, dynamic>;
    final token = row['token'] as String;
    Params.setValue('token', token);

    debugPrint('signup token = $token');
    debugPrint('BODY = ${res.body}');

    // On fait un nouvel appel API pour obtenir les infos de l'utilisateur courant
    final userRes = await ApiClient.post(
      'get_user_data',
      anonymous: false, // Ce flag indique que le token est utilisé dans les headers
    );

    final userData = jsonDecode(userRes.body) as Map<String, dynamic>;
    return User.fromJson(userData);

  }


  Future<bool> checkEmailAvailable(String email) async {
    final res = await ApiClient.get(
      'check_email_available?email=${Uri.encodeComponent(email)}',
      anonymous: true,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to check email (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    // si le SQL renvoie un bool, c’est déjà un bool
    if (data is bool) return data;
    
    if (data is List && data.isNotEmpty) {
      return (data.first as Map<String, dynamic>).values.first as bool;
    }
    throw Exception('Unexpected format: $data');
  }



  Future<bool> checkNameAvailable(String fullName) async {
    final res = await ApiClient.get(
      // le nom du paramètre doit matcher celui du SQL : full_name
      'check_full_name_available?full_name=${Uri.encodeComponent(fullName)}',
      anonymous: true,
    );
    debugPrint('HTTP ${res.statusCode}  ${res.body}');
    if (res.statusCode != 200) {
      throw Exception('Failed to check name (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is bool) return data;                       // si renvoyé direct
    if (data is List && data.isNotEmpty) {               // si renvoyé [{…}]
      return (data.first as Map<String, dynamic>).values.first as bool;
    }
    throw Exception('Unexpected response: $data');
  }



}
