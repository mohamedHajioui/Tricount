import 'package:flutter/material.dart';
import 'package:prbd_2425_a07/models/depense.dart';
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
  // Ajouter une nouvelle dépense
  Future<void> addDepense({
    required String title,
    required double amount,
    required DateTime operationDate,
    required int initiator,
    required List<Repartition> repartitions,
  }) async {
    if (_tricount == null) {
      _error = "Aucun tricount sélectionné";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Appel à la méthode statique de création de Depense
      await Depense.createOperation(
        tricountId: _tricount!.id,
        title: title,
        amount: amount,
        operationDate: operationDate,
        initiator: initiator,
        repartitions: repartitions,
      );
      // refresh
      await refresh();
    } catch (e, stackTrace) {
      print("ERREUR DÉTAILLÉE: $e");
      print("STACK TRACE: $stackTrace");
      _error = "Erreur lors de l'ajout de la dépense: ${e.toString()}";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Modifier une dépense existante
  Future<void> updateDepense({
    required int depenseId,
    required String title,
    required double amount,
    required DateTime operationDate,
    required int initiator,
    required List<Repartition> repartitions,
  }) async {
    if (_tricount == null) {
      _error = "Aucun tricount sélectionné";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Créer une instance temporaire de Depense pour l'update
      final depenseToUpdate = Depense(
        id: depenseId,
        title: title,
        amount: amount,
        operationDate: operationDate,
        createdAt: DateTime.now(), // Valeur temporaire, sera ignorée par l'API
        initiator: initiator,
        repartitions: repartitions,
      );

      // Appeler la méthode d'instance pour mise à jour
      await depenseToUpdate.saveOperation(_tricount!.id);

      // Refresh 
      await refresh();
    } catch (e) {
      _error = "Erreur lors de la modification de la dépense: ${e.toString()}";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Supprimer une dépense
  Future<void> deleteDepense(int depenseId) async {
    if (_tricount == null) {
      _error = "Aucun tricount sélectionné";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Appel à une méthode de suppression (à implémenter dans votre service API)
      // await ApiClient.post(' delete_operation', body: json.encode({"id": depenseId}));

      // Une autre approche serait d'ajouter une méthode statique à Depense:
      // await Depense.deleteOperation(depenseId);

      // refresh pareil encore
      await refresh();
    } catch (e) {
      _error = "Erreur lors de la suppression de la dépense: ${e.toString()}";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Trouver une dépense par son ID
  Depense? findDepenseById(int depenseId) {
    if (_tricount == null) return null;
    try {
      return _tricount!.depenses.firstWhere((dep) => dep.id == depenseId);
    } catch (e) {
      return null; // Retourne null si la dépense n'est pas trouvée
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
      final totalWeight = dep.repartitions.fold(0, (sum, r) => sum + (r.weight??0));
      print('Total weight: $totalWeight');

      // Trouver le poids de l'utilisateur courant
      final userRepartition = dep.repartitions
          .firstWhere((r) => r.user == userId,
          orElse: () => Repartition(user: userId, weight: 0));
      print('User weight: ${userRepartition.weight}');
      print('Amount: ${dep.amount}');
      print('Part: ${dep.amount * (userRepartition.weight??0) / totalWeight}');

      // Calculer sa part
      return sum + (dep.amount * (userRepartition.weight??0) / totalWeight);
      
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