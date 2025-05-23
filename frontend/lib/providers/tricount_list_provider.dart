import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/tricount_list_service.dart';
import 'package:prbd_2425_a07/models/user.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';

final tricountservice = Provider<tricount_list_service>((_) => tricount_list_service());

class TricountListNotifyer extends AsyncNotifier<List<Tricount>?>{
  Future<List<Tricount>> build() async {
    // Call the service and return the list immediately when this provider is first used
    return await ref.read(tricountservice).getTricountList();
  }
  
  Future<void> refreshTriCountList() async{
    state = await AsyncValue.guard(() =>
        ref.read(tricountservice).getTricountList());
  }
  
  
}


final tricountnotifyer =
AsyncNotifierProvider<TricountListNotifyer, List<Tricount>?>(() => TricountListNotifyer()); 