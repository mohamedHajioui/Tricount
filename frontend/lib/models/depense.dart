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
}
