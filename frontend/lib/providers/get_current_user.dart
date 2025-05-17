import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/users_service.dart';
import 'package:prbd_2425_a07/models/user.dart';

final logged_user_service = Provider<users_service>((_)=>users_service());

class LoggedUserNotifyer extends AsyncNotifier<User?>{
  Future<User?> build() async{
    return await ref.read(logged_user_service).get_current_user();
  }

  Future<void> refreshUsersList()async{
    state = await AsyncValue.guard(() =>
        ref.read(logged_user_service).get_current_user());
  }
}

final logged_usernotifyer = AsyncNotifierProvider<LoggedUserNotifyer, User?>(() => LoggedUserNotifyer()); 