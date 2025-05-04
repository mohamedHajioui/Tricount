// tricount_expense_card.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/models/depense.dart';
import 'package:prbd_2425_a07/providers/current_tricount_provider.dart';

class OperationCard extends ConsumerWidget {
  final Depense depense;

  const OperationCard({required this.depense, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tricount = ref.watch(currentTricountProvider).tricount;
    final initiator = tricount?.participants
        .firstWhere((p) => p.id == depense.initiator);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          depense.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Paid by ${initiator?.fullName ?? 'Unknown'}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${depense.amount.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              depense.operationDate.toString().split(' ')[0],  // Juste la date
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

