import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/services/balance_service.dart';
import '../models/UserBalance.dart';


final balanceServiceProvider = Provider((ref) => BalanceService());
final currentTricountId = StateProvider<int?>((ref)=> null);

class BalanceNotifier extends AsyncNotifier<List<UserBalance>?>{
  @override
  Future<List<UserBalance>?> build() async{
    final tricountId = ref.watch(currentTricountId);
    if(tricountId == null){
      return null;
    }
    return await ref.read(balanceServiceProvider).getTricountBalance(tricountId);
  }
}
final balanceProvider = AsyncNotifierProvider<BalanceNotifier, List<UserBalance>?> (BalanceNotifier.new);

