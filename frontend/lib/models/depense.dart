import 'dart:convert';

import 'package:prbd_2425_a07/core/services/api_client.dart';
import 'package:prbd_2425_a07/models/repartition.dart';

class Depense {
  final int id;
  final String title;
  final double amount;
  final DateTime operationDate;
  final DateTime createdAt;
  final int initiator;
  final List<Repartition> repartitions;

  Depense({
    required this.id,
    required this.title,
    required this.amount,
    required this.operationDate,
    required this.createdAt,
    required this.initiator,
    required this.repartitions,
  });

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      operationDate: DateTime.parse(json['operation_date']),
      createdAt: DateTime.parse(json['created_at']),
      initiator: json['initiator'],
      repartitions: (json['repartitions'] as List)
          .map((r) => Repartition.fromJson(r))
          .toList(),
    );
  }
  // Pour une dépense existante (modification)
  Future<void> saveOperation(int tricountId) async {
    final Map<String, dynamic> body = {
      "id": id,
      "tricount_id": tricountId,
      "title": title,
      "amount": amount,
      "operation_date": operationDate.toIso8601String(),
      "initiator": initiator,
      "repartitions": repartitions.map((r) => {
        "user": r.user,
        "weight": r.weight
      }).toList()
    };

    final response = await ApiClient.post(
      'save_operation', 
      body: json.encode(body),
    );

    if (response.statusCode != 200) {  
      throw Exception('Failed to update operation: ${response.body}');
    }
  }

// Méthode statique pour créer une nouvelle dépense
  static Future<Depense> createOperation({
    required int tricountId,
    required String title,
    required double amount,
    required DateTime operationDate,
    required int initiator,
    required List<Repartition> repartitions,
  }) async {
    final Map<String, dynamic> body = {
      "id": 0,  // 0 pour création
      "tricount_id": tricountId,
      "title": title,
      "amount": amount,
      "operation_date": operationDate.toIso8601String(),
      "initiator": initiator,
      "repartitions": repartitions.map((r) => {
        "user": r.user,
        "weight": r.weight
      }).toList()
    };
    
    final response = await ApiClient.post(
      'save_operation',
      body: json.encode(body),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to create operation: ${response.body}');
    }
    // Parse la réponse pour créer un nouvel objet Depense
    final responseData = json.decode(response.body);
    return Depense.fromJson(responseData);
    
  }

  // Méthodes utiles
  double getPartAmount(int userId) {
    final totalWeight = repartitions.fold(0, (sum, r) => sum + (r.weight ?? 0));
    final userRepartition = repartitions.firstWhere(
          (r) => r.user == userId,
      orElse: () => Repartition(user: userId, weight: 0),
    );
    return (amount * (userRepartition.weight??0)) / totalWeight;
  }

  bool isParticipant(int userId) =>
      repartitions.any((r) => r.user == userId);
  
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }
  // Validation du montant
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'required';
    }
    try {
      double amount = double.parse(value.replaceAll(',', '.'));
      if (amount < 0.01) {
        return 'minimum 0.01 €';
      }
    } catch (_) {
      return 'Please enter a valid number';
    }
    return null;
  }
  // Validation de la date d'opération
  static String? validateOperationDate(DateTime? date, DateTime? tricountCreationDate) {
    if (date == null) {
      return 'required';
    }

    if (date.isAfter(DateTime.now())) {
      return 'date may not be in the future';
    }

    if (tricountCreationDate != null) {
      final opDate = DateTime(date.year, date.month, date.day);
      final tricountDate = DateTime(tricountCreationDate.year, tricountCreationDate.month, tricountCreationDate.day);

      if (opDate.isBefore(tricountDate)) {
        return 'may not be before the tricount creation date';
      }
    }

    return null;
  }

  // Validation des répartitions
  static String? validateRepartitions(Map<int, int> weights) {
    if (weights.values.every((weight) => weight <= 0)) {
      return 'at least one participant must be selected';
    }
    return null;
  }
  //normalement ya toujours un intiator de selected par defaut mais je met la verif quand meme
  static String? validateInitiator(int? value) {
    if (value == null) {
      return 'Please select who paid';
    }
    return null;
  }
 
}
