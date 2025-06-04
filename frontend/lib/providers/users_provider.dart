import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/users_service.dart';
import 'package:prbd_2425_a07/models/user.dart';

final users_list_service = Provider<users_service>((_) => users_service());



final users_listnotifyer = FutureProvider<List<User>>((ref) async {
  return await ref.read(users_list_service).getAllUsers();
});