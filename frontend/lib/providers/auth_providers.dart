import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/services/auth_service.dart';
import 'package:prbd_2425_a07/models/user.dart';

final authServiceProvider = Provider((_) => AuthService());

class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController(this._read) : super(const AsyncValue.data(null));
  final Ref _read;

  Future<void> login(String email, String pwd) async {
    state = const AsyncValue.loading();
    try {
      final user = await _read.read(authServiceProvider).login(email, pwd);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider =
StateNotifierProvider<AuthController, AsyncValue<User?>>(
      (ref) => AuthController(ref),
);