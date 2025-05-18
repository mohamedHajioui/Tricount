import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/users_service.dart';
import 'package:prbd_2425_a07/models/user.dart';

final users_list_service = Provider<users_service>((_) => users_service());

class UserListNotifyer extends AsyncNotifier<List<User>>{
  Future<List<User>> build() async{
    return await ref.read(users_list_service).getAllUsers();
  }
  
  
  Future<void> refreshUsersList()async{
    state = await AsyncValue.guard(() =>
        ref.read(users_list_service).getAllUsers());
  }
}

final users_listnotifyer = AsyncNotifierProvider<UserListNotifyer, List<User>>(() => UserListNotifyer()); 