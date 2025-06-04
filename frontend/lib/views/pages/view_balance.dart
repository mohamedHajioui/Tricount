import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/providers/balance_provider.dart';
import 'package:prbd_2425_a07/providers/current_tricount_provider.dart';




class ViewBalance extends ConsumerStatefulWidget{
  static const routeName = '/viewbalance';
  final int tricountId;
  const ViewBalance({super.key, required this.tricountId});

  @override
  ConsumerState<ViewBalance> createState() => _viewBalanceState();
}

class _viewBalanceState extends ConsumerState<ViewBalance>{
  @override
  void initState() {
    super.initState();
    // Mets à jour l’id du tricount courant au montage de la page
    Future.microtask(() {
      ref.read(currentTricountId.notifier).state = widget.tricountId;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final balancesAsync = ref.watch(balanceProvider);
    final tricountState = ref.watch(currentTricountProvider);
    final participants = tricountState.tricount?.participants ?? [];
    final creatorId = tricountState.tricount?.creator;
    
    String getUserName(int userId) {
      final user = participants.where((u) => u.id == userId).toList();
      return user.isNotEmpty ? user.first.fullName : 'User $userId';
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.read(currentTricountProvider.notifier).refresh();
              ref.invalidate(balanceProvider);//force le refresh du provider balance
            },
          ),
        ],
      ),
      body: balancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (balances) {
          print('balances: $balances');
          if (balances == null || balances.isEmpty) {
            return const Center(child: Text("Aucune balance à afficher."));
          }
          final sorted = [...balances]
            ..sort((a, b) => getUserName(a.userId).toLowerCase().compareTo(getUserName(b.userId).toLowerCase()));          
          return ListView(
            shrinkWrap: true,
            children: sorted.map((ub) {
              final isNegative = ub.balance <= 0;
              final isZero = ub.balance == 0;
              final balanceWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isZero ? null : (isNegative ? Colors.red[300] : Colors.green[300]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${ub.balance.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              );
              String displayName = getUserName(ub.userId);
              final isCreator = ub.userId == creatorId; // Mets ta logique ici
              final nameWidget = Text.rich(
                TextSpan(
                  text: displayName,
                  style: TextStyle(
                    fontWeight: isCreator ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: isCreator
                    ? [
                      const TextSpan(
                        text: "(Creator)",
                        style: TextStyle(fontWeight: FontWeight.bold)
                      )
                  ]
                    : [],
                ),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ub.balance < 0
                      ? [balanceWidget, const SizedBox(width: 12), nameWidget]
                      : [nameWidget, const SizedBox(width: 12), balanceWidget],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }


}