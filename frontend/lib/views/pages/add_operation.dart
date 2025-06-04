import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2425_a07/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2425_a07/models/depense.dart';
import 'package:prbd_2425_a07/models/repartition.dart';
import 'package:prbd_2425_a07/models/user.dart';
import 'package:prbd_2425_a07/providers/current_tricount_provider.dart';
import 'package:prbd_2425_a07/providers/auth_service_provider.dart';

class AddOperationPage extends ConsumerStatefulWidget {
  final int tricountId;
  final int? depenseId; // Null pour ajout, non-null pour édition

  const AddOperationPage({
    required this.tricountId,
    this.depenseId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<AddOperationPage> createState() => _AddOperationPageState();
}

class _AddOperationPageState extends ConsumerState<AddOperationPage> {
  late ValidatingTextEditingController _titleController;
  late ValidatingTextEditingController _amountController;

  late DateTime _selectedDate;
  String? _dateError;

  int? _selectedInitiator;
  String? _initiatorError;

  Map<int, int> _weights = {}; // Map userId -> weight
  String? _repartitionsError;

  bool _isLoading = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    // Initialiser les contrôleurs avec validateurs
    _titleController = ValidatingTextEditingController(
      validator: Depense.validateTitle,
    );
    _titleController.onAfterValidated = () => setState(() {});

    _amountController = ValidatingTextEditingController(
      validator: Depense.validateAmount,
    );
    _amountController.onAfterValidated = () => setState(() {});

    // Charger les données existantes si c'est une édition
    _loadExistingData();
  }

  void _validateDate() {
    final tricount = ref.read(currentTricountProvider).tricount;
    if (tricount != null) {
      setState(() {
        _dateError = Depense.validateOperationDate(
            _selectedDate,
            tricount.dateHour
        );
      });
    }
  }

  void _validateInitiator() {
    setState(() {
      _initiatorError = Depense.validateInitiator(_selectedInitiator);
    });
  }

  void _validateRepartitions() {
    setState(() {
      _repartitionsError = Depense.validateRepartitions(_weights);
    });
  }

  // Valider tous les champs manuels (non géré par ValidatingTextEditingController)
  void _validateManualFields() {
    _validateDate();
    _validateInitiator();
    _validateRepartitions();
  }

  Future<void> _loadExistingData() async {
    if (widget.depenseId != null) {
      // C'est une édition, charger la dépense existante
      final tricountNotifier = ref.read(currentTricountProvider.notifier);
      final depense = tricountNotifier.findDepenseById(widget.depenseId!);

      if (depense != null) {
        setState(() {
          _titleController.text = depense.title;
          _amountController.text = depense.amount.toString();
          _selectedDate = depense.operationDate;
          _selectedInitiator = depense.initiator;

          // Initialiser les poids
          for (var rep in depense.repartitions) {
            if(rep.user != null) {
              _weights[rep.user!] = rep.weight ?? 0;
            }
            
          }
        });
      }
    } else {
      // Pour un ajout, initialiser l'initiateur avec l'utilisateur courant
      final currentUser = ref.read(authUserProvider).value;
      final tricount = ref.read(currentTricountProvider).tricount;
      if (currentUser != null) {
        setState(() {
          _selectedInitiator = currentUser.id;
          
        });
      }
      if(tricount != null) {
        setState(() {
          for (var participant in tricount.participants) {
            _weights[participant.id] = 1;
          }
        });
      }
    }

    // Valider les champs manuels initiaux
    _validateManualFields();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _validateDate();
      });
    }
  }

  void _incrementWeight(int userId) {
    setState(() {
      _weights[userId] = (_weights[userId] ?? 0) + 1;
      _validateRepartitions();
    });
  }

  void _decrementWeight(int userId) {
    setState(() {
      int currentWeight = _weights[userId] ?? 0;
      if (currentWeight > 0) {
        _weights[userId] = currentWeight - 1;
        _validateRepartitions();
      }
    });
  }
  Future<void> _deleteOperation() async {
    // Afficher une boîte de dialogue de confirmation
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
            'Are you sure you want to delete this operation?',
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // Si l'utilisateur confirme la suppression
    if (confirm == true) {
      final tricountNotifier = ref.read(currentTricountProvider.notifier);
      await tricountNotifier.deleteDepense(depenseId: widget.depenseId!);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveOperation() async {
    // Valider tous les champs avant soumission
    await _titleController.validateAndWait();
    await _amountController.validateAndWait();
    _validateManualFields();

    // Vérifier si le formulaire est valide
    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    try {
      final double amount = double.parse(_amountController.text.replaceAll(',', '.'));

      // Préparer les répartitions
      List<Repartition> repartitions = [];
      _weights.forEach((userId, weight) {
        if (weight > 0) {
          repartitions.add(Repartition(user: userId, weight: weight));
        }
      });

      final tricountNotifier = ref.read(currentTricountProvider.notifier);

      if (widget.depenseId == null) {
        // Ajout d'une nouvelle dépense
        await tricountNotifier.addDepense(
          title: _titleController.text,
          amount: amount,
          operationDate: _selectedDate,
          initiator: _selectedInitiator!,
          repartitions: repartitions,
        );
      } else {
        // Modification d'une dépense existante
        await tricountNotifier.updateDepense(
          depenseId: widget.depenseId!,
          title: _titleController.text,
          amount: amount,
          operationDate: _selectedDate,
          initiator: _selectedInitiator!,
          repartitions: repartitions,
        );
      }

      // Retourner à l'écran précédent après succès
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Analyser l'erreur pour déterminer le champ concerné
      String errorMessage = e.toString();

      // Logique pour répartir l'erreur au bon champ
      if (errorMessage.contains("title")) {
        _titleController.validate(); // Forcer une revalidation
      } else if (errorMessage.contains("amount")) {
        _amountController.validate(); // Forcer une revalidation
      } else if (errorMessage.contains("operation_date") || errorMessage.contains("date")) {
        setState(() {
          _dateError = errorMessage;
        });
      } else if (errorMessage.contains("participant") || errorMessage.contains("repartition")) {
        setState(() {
          _repartitionsError = errorMessage;
        });
      } else {
        setState(() {
          _generalError = errorMessage;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool get _isFormValid =>
      _titleController.isValid == true &&
          _amountController.isValid == true &&
          _dateError == null &&
          _initiatorError == null &&
          _repartitionsError == null;

  // Méthode pour le champ de titre
  Widget _titleFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    
    final isTitleValid = _titleController.text.trim().isNotEmpty && _titleController.errorText == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: 'Title (*)',
            labelStyle: TextStyle(
              color: isTitleValid ? Colors.grey : Colors.red,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isTitleValid ? Colors.grey : Colors.red,
                width: 1,
              ),
            ),

            // Contour quand le champ a le focus
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isTitleValid ? Colors.blue : Colors.red,
                width: 2,
              ),
            ),
            border: const OutlineInputBorder(),
            errorText: _titleController.errorText,
          ),
          onChanged: (text) {
            // Obligatoire pour que le champ se rebuild à chaque changement
            // → à mettre dans un StatefulWidget, avec setState() !
            (context as Element).markNeedsBuild(); // Ou mieux : setState(() {});
          },
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }

  // Méthode pour le champ de montant
  Widget _amountFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    final isAmountValid =_amountController.text.trim().isNotEmpty && _amountController.errorText == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _amountController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '€ ',
            prefixStyle: const TextStyle(color: Colors.black),
            labelText: 'Amount (*)',
            labelStyle: TextStyle(
              color: isAmountValid ? Colors.grey : Colors.red,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isAmountValid ? Colors.grey : Colors.red,
                width: 1,
              ),
            ),

            // Contour quand le champ a le focus
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isAmountValid ? Colors.blue : Colors.red,
                width: 2,
              ),
            ),
            border: const OutlineInputBorder(),
            errorText: _amountController.errorText,
          ),
          onChanged: (_) {
            // Nécessaire pour que la couleur change dynamiquement
            (context as Element).markNeedsBuild();
          },
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }

  // Méthode pour le champ de date
  Widget _dateFormField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operation Date (*)',
          style: TextStyle(color: Colors.grey),
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Select date',
                suffixIcon: const Icon(Icons.calendar_today),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                errorText: _dateError,
              ),
              controller: TextEditingController(
                text: DateFormat('dd/MM/yyyy').format(_selectedDate),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Méthode pour le champ d'initiateur
  Widget _initiatorFormField(BuildContext context) {
    final tricount = ref.watch(currentTricountProvider).tricount;
    if (tricount == null) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paid by (*)',
          style: TextStyle(color: Colors.grey),
        ),
        DropdownButtonFormField<int>(
          value: _selectedInitiator,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorText: _initiatorError,
          ),
          items: tricount.participants.map((User user) {
            return DropdownMenuItem<int>(
              value: user.id,
              child: Text(user.fullName),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              _selectedInitiator = newValue;
              _validateInitiator();
            });
          },
        ),
      ],
    );
  }

  // Méthode pour la section de répartition
  Widget _repartitionsSection(BuildContext context) {
    final tricount = ref.watch(currentTricountProvider).tricount;
    ref.watch(currentTricountProvider).refresh();
    
    if (tricount == null) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'From whom?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (_repartitionsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _repartitionsError!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        const SizedBox(height: 8),
        ...tricount.participants.map((user) => _participantRow(user)).toList(),
      ],
    );

  }

  // Méthode pour chaque ligne de participant
  Widget _participantRow(User user) {
    final weight = _weights[user.id] ?? 0;
    final amount = weight > 0 && double.tryParse(_amountController.text.replaceAll(',', '.')) != null
        ? (double.parse(_amountController.text.replaceAll(',', '.')) * weight) /
        (_weights.values.fold(0, (sum, w) => sum + w))
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: weight > 0,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _weights[user.id] = 1;
                } else {
                  _weights[user.id] = 0;
                }
                _validateRepartitions();
              });
            },
          ),
          Expanded(
            child: Text(user.fullName),
          ),
          Text(
            weight > 0 ? '${weight}x' : '0x',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text('${amount.toStringAsFixed(2)} €'),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: weight > 0
                      ? () => _decrementWeight(user.id)
                      : null,
                ),
                IconButton( 
                  icon: const Icon(Icons.add),
                  onPressed: () => _incrementWeight(user.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tricountState = ref.watch(currentTricountProvider);
    final tricount = tricountState.tricount;
    final isEditing = widget.depenseId != null;

    if (tricountState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Modifier l\'opération' : 'Ajouter une opération'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (tricount == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Modifier l\'opération' : 'Ajouter une opération'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Tricount non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Operation' : 'Add Operation',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _isLoading ? null : _saveOperation,
          ),
          if(isEditing) // si c'est edit on affiche delete 
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _isLoading ? null : _deleteOperation,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message d'erreur générale
              if (_generalError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _generalError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Utiliser les méthodes dédiées pour chaque champ
              _titleFormField(context, (_) => _saveOperation()),
              const SizedBox(height: 16),

              _amountFormField(context, (_) => _saveOperation()),
              const SizedBox(height: 16),

              _dateFormField(context),
              const SizedBox(height: 16),

              _initiatorFormField(context),
              const SizedBox(height: 24),

              _repartitionsSection(context),

              // Bouton Enregistrer pour les petits écrans
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              ,
            ],
          ),
        ),
      ),
    );
  }
}
