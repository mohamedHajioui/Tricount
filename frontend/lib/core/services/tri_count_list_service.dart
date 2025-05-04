

import 'dart:convert';

import 'package:prbd_2425_a07/core/services/api_client.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';

class tricount_list_server{
  Future<List<Tricount>> getTricountList() async{
    final res = await ApiClient.post('get_my_tricounts',anonymous: true);
    
    if(res.statusCode != 200){
      throw Exception("You are not connected");
    }
    
    final decoded = jsonDecode(res.body);
    List<Tricount> tricounts = [];
    
    for (var tricount in decoded){
      tricounts.add(Tricount.formJson(tricount));
    }
    
    return tricounts;
  }
}