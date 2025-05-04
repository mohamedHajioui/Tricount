// tricount_expense_card.dart
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/models/depense.dart';

class OperationCard extends StatelessWidget {
  final Depense depense;

  const OperationCard({required this.depense, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // La carte pour une dépense
  }
}

// tricount_total_bar.dart
class TricountTotalBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // La barre du bas avec MY TOTAL et TOTAL EXPENSES
  }
}

// tricount_balance_button.dart
class TricountBalanceButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TricountBalanceButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Le bouton vert View Balance
  }
}