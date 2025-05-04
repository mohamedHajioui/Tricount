import 'package:flutter/material.dart';
import 'package:prbd_2425_a07/models/Tricount.dart';
import 'package:prbd_2425_a07/core/services/tricount_list_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CurrentTricountNotifier extends ChangeNotifier {
  Tricount? _tricount;
  bool _isLoading = false;
  String? _error;

  // Getters
  Tricount? get tricount => _tricount;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
    // TODO: Implémenter le calcul de MY TOTAL
    return 0.0;
  }

  double _calculateTotalExpenses() {
    /*if (_tricount == null) return 0.0;
    return _tricount!.depenses.fold(0, (sum, dep) => sum + dep.amount);*/
    return 0.0;
  }
}

// Création du provider
final currentTricountProvider = ChangeNotifierProvider<CurrentTricountNotifier>((ref) {
  return CurrentTricountNotifier();
});