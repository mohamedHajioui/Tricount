import 'dart:convert';
import 'package:flutter/cupertino.dart';

import 'api_client.dart';
import 'package:prbd_2425_a07/models/user.dart';
import '../tools/params.dart';

class AuthService {
  //Retourne l'utilisateur + stocke le token
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
    Params.setValue('token', token);

    return User(id: 0, email: email, token: token, fullName: '');
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
        'confirm_password': password,
      }),
    );
    debugPrint('HTTP ${res.statusCode}  ${res.body}');


    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message']);
    }
    
    final row = (jsonDecode(res.body) as List).first as Map<String, dynamic>;
    final token = row['token'] as String;
    Params.setValue('token', token);
    debugPrint('signup token = $token');
    debugPrint('BODY = ${res.body}');
    return User.fromJson(row);
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
