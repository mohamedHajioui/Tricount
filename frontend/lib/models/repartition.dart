class Repartition {
  final int user;
  final int? weight;

  Repartition({
    required this.user,
    required this.weight,
  });

  factory Repartition.fromJson(Map<String, dynamic> json) {
    return Repartition(
      user: json['user'],
      weight: json['weight'],
    );
  }

  // Pour debugger
  @override
  String toString() => 'Repartition(user: $user, weight: $weight)';
}