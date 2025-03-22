import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:prbd_2425_a07/core/tools/debounce.dart';

class ValidatingTextEditingController extends TextEditingController {
  // validateur synchrone
  String? Function(String value)? validator;

  // validateur asynchrone
  Future<String?> Function(String value)? asyncValidator;

  // callback appelé après la validation
  void Function()? onAfterValidated;

  // message d'erreur
  String? _errorText;

  // la validation est en cours
  bool _isValidating = false;

  // le champ est vierge (non modifié par l'utilisateur)
  bool _isPristine = true;

  // le contrôleur a été supprimé
  bool _isDisposed = false;

  // tâche asynchrone en cours
  CancelableOperation? _task;

  // debouncer pour la validation asynchrone
  final Debouncer _debouncer = Debouncer();

  ValidatingTextEditingController({
    this.validator,
    this.asyncValidator,
    this.onAfterValidated,
    initialValue,
  }) : super(text: initialValue);

  bool get isValidating => _isValidating;

  bool get isPristine => _isPristine;

  String? get errorText => _errorText;

  bool? get isValid => _isValidating ? null : (_errorText == null);

  /// On surcharge le setter de [value] pour intercepter les changements de texte
  /// et déclencher la validation.
  @override
  set value(TextEditingValue newValue) {
    if (_isDisposed) return;
    if (newValue.text != text) {
      _isPristine = false;
      super.value = newValue;
      validate();
    } else {
      super.value = newValue;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// On surcharge la méthode [notifyListeners] pour éviter de notifier les écouteurs
  /// si le contrôleur a été supprimé.
  @override
  notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  /// Cette méthode permet de valider le texte actuel en exécutant les validateurs
  /// synchrone et asynchrone, s'ils sont définis. Le validateur asynchrone est
  /// appelé de manière synchrone (avec un await).
  Future<void> validateAndWait() async {
    if (_isDisposed) return;

    if (validator == null) return;
    _errorText = validator!(text);
    if (asyncValidator != null) {
      _errorText ??= await asyncValidator!(text);
    }
    notifyListeners();
    onAfterValidated!();
  }

  /// Cette méthode permet de valider le texte actuel en exécutant les validateurs
  /// synchrone et asynchrone, s'ils sont définis. Le validateur asynchrone est
  /// appelé de manière asynchrone (sans await). La méthode utilise aussi le
  /// principe de [*debouncing*](https://developer.mozilla.org/en-US/docs/Glossary/Debounce) 
  /// pour éviter de lancer plusieurs fois la validation
  /// asynchrone si l'utilisateur appelle plusieurs fois la méthode avant que la
  /// validation précédente ne soit terminée.
  void validate() {
    if (_isDisposed) return;

    _isValidating = true;

    // effectuer la validation synchrone
    _errorText = validator?.call(text);
    notifyListeners();

    // si un validateur asynchrone est défini et la validation synchrone est réussie
    if (asyncValidator != null && _errorText == null) {
      // annuler la tâche en cours, s'il y en a une
      _task?.cancel();

      // utiliser le debouncer pour gérer le délai avant validation asynchrone
      _debouncer.call(() async {
        try {
          // réinitialiser l'erreur avant de valider
          _errorText = null;
          notifyListeners();

          // créer une opération annulable pour la validation asynchrone
          _task = CancelableOperation.fromFuture(
            asyncValidator!.call(text),
          );

          // attendre le résultat de la validation asynchrone
          final error = await _task?.value;
          _errorText = error;
        } finally {
          // toujours remettre l'état de validation à false
          _isValidating = false;
          notifyListeners();
          onAfterValidated?.call();
        }
      });
    } else {
      // si aucune validation asynchrone n'est nécessaire, remettre l'état immédiatement
      _isValidating = false;
      notifyListeners();
      onAfterValidated?.call();
    }
  }
}
