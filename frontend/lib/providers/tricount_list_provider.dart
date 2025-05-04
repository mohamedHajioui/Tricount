import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/tricount_list_service.dart';
import 'package:prbd_2425_a07/models/user.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';

final tricountservice = Provider<tricount_list_service>((_) => tricount_list_service());

class TricountListNotifyer extends AsyncNotifier<List<Tricount>?>{
  Future<List<Tricount>?> build() async => null;
  
  Future<List<Tricount>> getTricountlist() async{
    state = await AsyncValue.guard(() =>
        ref.read(tricountservice).getTricountList());
    
  }
}