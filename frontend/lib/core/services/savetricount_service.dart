import 'dart:convert';
import 'package:prbd_2425_a07/core/services/api_client.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';

class savetricount_service{
  Future<void> save_tricount(Tricount tricount) async{

    final res = await ApiClient.post(
      'save_tricount',
      body: jsonEncode({
        "id": tricount.id,
        "title": tricount.title,
        "description": tricount.description,
        "creator_id": tricount.creator,
        "participants": tricount.participants.map((u) => u.id).toList(),
      }),
    );
    
    if(res.statusCode != 200) {
      throw Exception('${res.statusCode}');
    }
  }
}