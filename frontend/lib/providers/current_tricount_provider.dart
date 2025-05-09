import 'package:flutter/material.dart';
import 'package:prbd_2425_a07/models/repartition.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';
import 'package:prbd_2425_a07/core/services/tricount_list_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_service_provider.dart';

class CurrentTricountNotifier extends ChangeNotifier {
  Tricount? _tricount;
  bool _isLoading = false;
  String? _error;

  // Getters
  Tricount? get tricount => _tricount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  final Ref ref;  

  CurrentTricountNotifier(this.ref);  

  // Pour le total en bas
  double get myTotal => _calculateMyTotal();
  double get totalExpenses => _calculateTotalExpenses();

  // Charger un tricount spécifique
  Future<void> loadTricount(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tricountList = await tricount_list_service().getTricountList();
      _tricount = tricountList.firstWhere((t) => t.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rafraîchir les données
  Future<void> refresh() async {
    if (_tricount != null) {
      await loadTricount(_tricount!.id);
    }
  }

  // Calculs des totaux
  double _calculateMyTotal() {
    if (_tricount == null) return 0.0;

    final userId = ref.read(authUserProvider).value?.id;
    print('Current user ID: $userId');
    if (userId == null) return 0.0;
    
    return _tricount!.depenses.fold(0.0, (sum, dep) {
      // Calculer le poids total
      final totalWeight = dep.repartitions.fold(0, (sum, r) => sum + r.weight);
      print('Total weight: $totalWeight');

      // Trouver le poids de l'utilisateur courant
      final userRepartition = dep.repartitions
          .firstWhere((r) => r.user == userId,
          orElse: () => Repartition(user: userId, weight: 0));
      print('User weight: ${userRepartition.weight}');
      print('Amount: ${dep.amount}');
      print('Part: ${dep.amount * userRepartition.weight / totalWeight}');

      // Calculer sa part
      return sum + (dep.amount * userRepartition.weight / totalWeight);
      
    });
    
  }

  double _calculateTotalExpenses() {
    if (_tricount == null) return 0.0;
    return _tricount!.depenses.fold(0, (sum, dep) => sum + dep.amount);
    /*return 0.0;*/
  }
}

// Création du provider
final currentTricountProvider = ChangeNotifierProvider<CurrentTricountNotifier>((ref) {
  return CurrentTricountNotifier(ref);
});