import 'dart:convert';

import 'package:prbd_2425_a07/core/services/api_client.dart';
import 'package:prbd_2425_a07/models/user.dart';

class users_service{
  Future<List<User>> getAllUsers() async{
    final res = await ApiClient.get('get_all_users',anonymous: false);
    
    if(res.statusCode != 200){
      throw Exception('Statussasa Code: ${res.statusCode}');
    }
    
    if(res.body.isEmpty) {
      return [];
    }
    
    final decoded_users =  jsonDecode(res.body);
    
    if(decoded_users == null) {
      return [];
    }
    
    List<User> all_users = [];
    for(var user in decoded_users) {
      all_users.add(User.fromJson(user));
    }
    
    return all_users;
  }
  
  Future<User?> get_current_user() async{
    final res = await ApiClient.get('get_user_data',anonymous: false);
    
    if(res.statusCode != 200){
      throw Exception('There is no connected User status code :${res.statusCode}');
    }
    if(res.body == null){
      return null;
    }
    
    final decoded_user = jsonDecode(res.body);
    if(decoded_user == null) {
      return null;
    }
    
    User user = User.fromJson(decoded_user[0]);
    return user;
  }
}