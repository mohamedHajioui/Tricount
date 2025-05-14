import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/services/auth_service.dart';
import 'package:prbd_2425_a07/models/user.dart';

final authServiceProvider = Provider<AuthService>((_) => AuthService());

// ─── AsyncNotifier<User?> ────────────────────────────────────────────────────
class AuthUserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async => null;          // pas connecté

  Future<void> login(String email, String pwd) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(authServiceProvider).login(email, pwd));
  }
  
  Future<void> signup(String email, String fullName, String iban, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
        ref.read(authServiceProvider).signup(email, fullName, iban, password));
    
  }
  

  void logout() => state = const AsyncData<User?>(null);
}

final authUserProvider =
    AsyncNotifierProvider<AuthUserNotifier, User?>(() => AuthUserNotifier());
