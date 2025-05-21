import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/services/balance_service.dart';
import '../models/UserBalance.dart';


final currentTricountIdProvider = StateProvider<int?> ((ref) => null);
final balanceServiceProvider = Provider((ref) => BalanceService());

class BalanceNotifier extends AsyncNotifier<List<UserBalance>?> {
  @override
  Future<List<UserBalance>?> build() async {
    // Récupère l'id du tricount courant
    final tricountId = ref.read(currentTricountIdProvider);
    if (tricountId == null) {
      return null;
    }
    return await ref.read(balanceServiceProvider).getTricountBalance(tricountId);
  }
}
final balanceProvider = AsyncNotifierProvider<BalanceNotifier, List<UserBalance>?>(BalanceNotifier.new);


