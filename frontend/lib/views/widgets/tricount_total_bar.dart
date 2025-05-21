// lib/views/widgets/tricount_total_bar.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/views/pages/add_operation.dart';
import '../../providers/current_tricount_provider.dart';

class TricountTotalBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tricountState = ref.watch(currentTricountProvider);
    final tricount = tricountState.tricount;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MY TOTAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${tricountState.myTotal.toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          FloatingActionButton(
            onPressed: tricount == null ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOperationPage(
                    tricountId: tricount.id,
                  ),
                ),
              );
            },
            backgroundColor: Colors.blue, // Couleur de fond bleue
            child: const Icon(
              Icons.add,
              color: Colors.white, // Icône blanche
            ),
            elevation: 2, // Légère élévation
            shape: const CircleBorder(), // Garantit une forme parfaitement ronde
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('TOTAL EXPENSES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${tricountState.totalExpenses.toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}