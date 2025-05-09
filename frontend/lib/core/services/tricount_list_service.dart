import 'dart:convert';

import 'package:prbd_2425_a07/core/services/api_client.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';

class tricount_list_service {
  Future<List<Tricount>> getTricountList() async {
    
      final res = await ApiClient.get('get_my_tricounts', anonymous: false);
      
      if (res.statusCode != 200) {
        throw Exception("Status code: ${res.statusCode}");
      }

      if (res.body.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(res.body);
      
      if (decoded == null) {
        
        return [];
      }
      List<Tricount> tricounts = [];
      for (var tricount in decoded) {
        tricounts.add(Tricount.fromJson(tricount));
      }
      return tricounts;
    
  }
}