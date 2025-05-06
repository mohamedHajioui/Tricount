import 'dart:convert';
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

    return User(id: 0, email: email, token: token);
  }
  
  Future<User> signup(String email, String fullName, String iban, String password) async {
    final res = await ApiClient.post(
      'signup',
      anonymous: true,
      body: jsonEncode({
        'email': email,
        'full_name': fullName,
        'iban': iban,
        'password': password,
        'confirm_password': password,
      }),
      headers: {'Prefer': 'params=single-object'},
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message']);
    }
    final row = (jsonDecode(res.body) as List).first as Map<String, dynamic>;
    final token = row['token'] as String;
    Params.setValue('token', token);
    return User.fromJson(row);
    
    
    
  }
}