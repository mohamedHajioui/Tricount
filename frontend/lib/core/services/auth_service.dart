import 'dart:convert';
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
}