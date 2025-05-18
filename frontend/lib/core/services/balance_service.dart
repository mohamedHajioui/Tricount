import 'dart:convert';
import 'package:prbd_2425_a07/models/UserBalance.dart';
import 'api_client.dart';

class BalanceService {
  Future<List<UserBalance>> getTricountBalance(int tricountId) async{
    final res = await ApiClient.get(
      'get_tricount_balance?tricount_id=$tricountId',
      anonymous: false
    );
    if(res.statusCode != 200){
      throw Exception('Erreur HTTP ${res.statusCode}');
    }
    final List data = jsonDecode(res.body);
    return data.map((e) => UserBalance.fromJson(e)).toList();
  }
}