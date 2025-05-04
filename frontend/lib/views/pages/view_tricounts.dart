import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';
import 'package:prbd_2425_a07/providers/tricount_list_provider.dart';
import '../widgets/tricound_card.dart'; // Your TricountCard widget

class TricountListPage extends ConsumerWidget {
  static const routeName = '/tricounts';
  const TricountListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tricountsAsync = ref.watch(tricountnotifyer);

    return Scaffold(
      appBar: AppBar(title: Text('My Tricounts')),
      body: tricountsAsync.when(
        data: (tricounts) {
          if (tricounts == null || tricounts.isEmpty) {
            return Center(child: Text('No tricounts found.'));
          }

          return ListView(
            children: tricounts.map((t) {
              return TricountCard(title: t.titre);
            }).toList(),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
