import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/services/api_client.dart';

class ResetDbController extends StateNotifier<AsyncValue<void>> {
  ResetDbController() : super(const AsyncValue.data(null));
  
  Future<void> reset(BuildContext ctx) async {
    state = const AsyncValue.loading();
    try {
      await ApiClient.post('reset_database', anonymous: true);
      if(ctx.mounted){
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('DB reset!')),
        );
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      if(ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text ('Reset error = $e')),
        );
      }
      state = AsyncValue.error(e, st);
    }
  }
}

final resetDbControllerProvider = 
    StateNotifierProvider<ResetDbController, AsyncValue<void>>(
        (_) => ResetDbController(),
    );