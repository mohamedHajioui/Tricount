import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:prbd_2425_a07/providers/current_tricount_provider.dart';
import 'package:prbd_2425_a07/views/widgets/operation_card.dart';
import 'package:prbd_2425_a07/views/widgets/tricount_total_bar.dart';

class TricountView extends ConsumerStatefulWidget {
  final int tricountId;

  const TricountView({required this.tricountId, Key? key}) : super(key: key);

  @override
  ConsumerState<TricountView> createState() => _TricountViewState();
}

class _TricountViewState extends ConsumerState<TricountView> {
  @override
  void initState() {
    super.initState();
    print("TricountView initState with ID: ${widget.tricountId}");
    // Charge le tricount après le build initial
    Future.microtask(() {
      try {
        print("Trying to load tricount with ID: ${widget.tricountId}");
        ref.read(currentTricountProvider.notifier).loadTricount(widget.tricountId);
      } catch (e) {
        print("Error during loadTricount: $e");
      }
    });
  }

  // Fonction pour afficher le contenu quand le tricount est vide
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your tricount is empty!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Click below to add your first expense!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implémenter la création de dépense
                // Cette fonction devrait être la même que celle du FAB dans TricountTotalBar
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Add an expense',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tricountState = ref.watch(currentTricountProvider);

    if (tricountState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tricountState.error != null) {
      return Scaffold(
        body: Center(child: Text('Error: ${tricountState.error}')),
      );
    }

    final tricount = tricountState.tricount;
    if (tricount == null) {
      return const Scaffold(
        body: Center(child: Text('Tricount not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tricount.title),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implémenter la vue des balances
            },
            child: const Text(
              'View Balance',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: tricount.depenses.isEmpty
                ? _buildEmptyState() // Utiliser notre état vide
                : RefreshIndicator(
              onRefresh: () async {
                // Rafraîchir les données quand on tire vers le bas
                await ref.read(currentTricountProvider.notifier).refresh();
              },
              child: ListView.builder(
                itemCount: tricount.depenses.length,
                itemBuilder: (context, index) {
                  return OperationCard(
                    depense: tricount.depenses[index],
                  );
                },
              ),
            ),
          ),
          TricountTotalBar(),
        ],
      ),
    );
  }
}