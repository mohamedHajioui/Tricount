import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/tools/params.dart';
import '../core/services/auth_service.dart';
import 'package:prbd_2425_a07/models/user.dart';
import 'package:prbd_2425_a07/providers/tricount_list_provider.dart';


final authServiceProvider = Provider<AuthService>((_) => AuthService());

// ─── AsyncNotifier<User?> ────────────────────────────────────────────────────
class AuthUserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async => null;          // pas connecté

  Future<void> login(String email, String pwd) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(authServiceProvider).login(email, pwd));
    ref.refresh(tricountnotifyer);
  }
  
  Future<void> signup(String email, String fullName, String iban, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
        ref.read(authServiceProvider).signup(email, fullName, iban, password));
    ref.refresh(tricountnotifyer);
  }
  

  void logout() {
    Params.clearValue('token');
    state = AsyncData(null);
  }
}

final authUserProvider =
    AsyncNotifierProvider<AuthUserNotifier, User?>(() => AuthUserNotifier());
