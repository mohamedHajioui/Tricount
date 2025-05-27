import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/savetricount_service.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';

final saveTricountServiceProvider =
Provider<savetricount_service>((ref) => savetricount_service());

class SaveTricountNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No-op: no state to load by default
  }

  Future<void> save(Tricount tricount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(saveTricountServiceProvider).save_tricount(tricount);
    });
  }
}

final saveTricountNotifierProvider =
AsyncNotifierProvider<SaveTricountNotifier, void>(() => SaveTricountNotifier());
