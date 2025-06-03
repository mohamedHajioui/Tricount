import 'dart:convert';

import 'package:prbd_2425_a07/core/services/api_client.dart';

class DeletetricountService {
  Future<void> deletetricountservice(int id) async {
    final body = jsonEncode({"tricount_id": id});

    final res = await ApiClient.post(
      'delete_tricount', 
      body: body,
      anonymous: false, 
    );


    if (res.statusCode != 200) {
      throw Exception("Delete failed: ${res.statusCode} - ${res.body}");
    }
  }
}