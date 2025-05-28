// lib/models/tricount.dart
import 'dart:convert';

import 'package:prbd_2425_a07/core/services/api_client.dart';
import 'package:prbd_2425_a07/models/depense.dart';
import 'package:prbd_2425_a07/models/repartition.dart';
import 'package:prbd_2425_a07/models/user.dart';

class Tricount {
  final int id;
  String title;
  String? description;
  final DateTime? dateHour;
  final int creator;
  List<User> participants;
  List<Depense> depenses;

  Tricount({
    required this.id,
    required this.title,
    this.description,
    required this.dateHour,
    required this.creator,
    required this.participants,
    required this.depenses,
  });

  factory Tricount.fromJson(Map<String, dynamic> json) {
    return Tricount(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateHour: DateTime.parse(json['created_at']),  // car le backend renvoie 'created_at'
      creator: json['creator'],
      participants: (json['participants'] as List?)?.map((p) => User.fromJson(p)).toList() ?? [],  // Gérer le null
      depenses: (json['operations'] as List?)?.map((d) => Depense.fromJson(d)).toList() ?? [],    // Gérer le null
    );
  }

  // Méthodes utiles pour les calculs
  double get totalExpenses =>
      depenses.fold(0, (sum, depense) => sum + depense.amount);

  // Trouve un participant par son ID
  User? findParticipant(int userId) =>
      participants.where((p) => p.id == userId).firstOrNull;  // retourne null si non trouvé

  // Trouve le nom du créateur
  String get creatorName =>
      findParticipant(creator)?.fullName ?? 'Unknown';

  List<int> unremovable_list_const(){
    List<int> unremovable = [];
    
    depenses.forEach ((Depense depense) {
      depense.repartitions.forEach((Repartition repartition){
        if( repartition.user != id){
          unremovable.add(repartition.user);
        }
      });
    });
    
    return unremovable;
  }


}