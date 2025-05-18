import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  late DateTime _selectedDate;
  int? _selectedInitiator;
  Map<int, int> _weights = {}; // Map userId -> weight

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Charger les données existantes si c'est une édition
    _loadExistingData();
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
            _weights[rep.user] = rep.weight ?? 0;
          }
        });
      }
    } else {
      // Pour un ajout, initialiser l'initiateur avec l'utilisateur courant
      final currentUser = ref.read(authUserProvider).value;
      if (currentUser != null) {
        setState(() {
          _selectedInitiator = currentUser.id;
        });
      }
    }
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
      });
    }
  }

  void _incrementWeight(int userId) {
    setState(() {
      _weights[userId] = (_weights[userId] ?? 0) + 1;
    });
  }

  void _decrementWeight(int userId) {
    setState(() {
      int currentWeight = _weights[userId] ?? 0;
      if (currentWeight > 0) {
        _weights[userId] = currentWeight - 1;
      }
    });
  }

  Future<void> _saveOperation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedInitiator == null) {
      setState(() {
        _errorMessage = "Veuillez sélectionner qui a payé";
      });
      return;
    }

    // Vérifier que au moins un participant a un poids > 0
    bool hasParticipant = _weights.values.any((weight) => weight > 0);
    if (!hasParticipant) {
      setState(() {
        _errorMessage = "Veuillez sélectionner au moins un participant";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
      setState(() {
        _errorMessage = "Erreur: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          
          IconButton(
            icon : const Icon(Icons.delete,color : Colors.white),
            onPressed: _isLoading ? null : _saveOperation,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message d'erreur
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Titre
              const Text(
                'Title (*)',
                style: TextStyle(color: Colors.grey),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Montant
              const Text(
                'Amount (*)',
                style: TextStyle(color: Colors.grey),
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixText: '€ ',
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  try {
                    double.parse(value.replaceAll(',', '.'));
                    return null;
                  } catch (_) {
                    return 'Please enter a valid number';
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date d'opération
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
                    ),
                    controller: TextEditingController(
                      text: DateFormat('dd/MM/yyyy').format(_selectedDate),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payé par
              const Text(
                'Paid by (*)',
                style: TextStyle(color: Colors.grey),
              ),
              DropdownButtonFormField<int>(
                value: _selectedInitiator,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select who paid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Liste des participants avec poids
              const Text(
                'From whom?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...tricount.participants.map((user) {
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
              }).toList(),

              // Bouton Enregistrer pour les petits écrans
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveOperation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(isEditing ? 'Update Operation' : 'Add Operation'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}