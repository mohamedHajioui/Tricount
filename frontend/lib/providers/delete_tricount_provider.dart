import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/deletetricount_service.dart';
import 'package:prbd_2425_a07/providers/tricount_list_provider.dart';



final trisountdeleteservice = Provider<DeletetricountService>((_) => DeletetricountService());

class TricountDeleteNotifyer extends AsyncNotifier<void> {
  Future<void> build() async {
    // No-op: no state to load by default
  }

  Future<void> delete(int i) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(trisountdeleteservice).deletetricountservice(i);
    });
    ref.refresh(tricountnotifyer);
  }


}


final deletetricountnotifyer =
AsyncNotifierProvider<TricountDeleteNotifyer, void>(() => TricountDeleteNotifyer()); 