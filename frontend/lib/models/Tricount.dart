// lib/models/tricount.dart
import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/api_client.dart';
import 'package:prbd_2425_a07/models/depense.dart';
import 'package:prbd_2425_a07/providers/tricount_list_provider.dart';

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
          unremovable.add(repartition.user);
        
      });
      unremovable.add(creator);
      
    });
    
    return unremovable;
  }

  static Future<bool> isTitleUnique(String title, int? currentId, WidgetRef ref) async {
    final tricounts = ref.read(tricountnotifyer).value;
    if (tricounts == null) return true;

    return !tricounts.any((t) =>
    t.title.toLowerCase() == title.toLowerCase() && t.id != currentId);
  }

  static Future<Map<String, String?>> validateInputs(
      String title,
      String description,
      int currentid,
      WidgetRef ref
      ) async {
    
    
    //les message d'errure qu'on va retourner
    String? newTitleError;
    String? newDescError;


    if (title.length < 3) {
      newTitleError = 'Title must be at least 3 characters';
    } else {
      final unique = await Tricount.isTitleUnique(title, currentid, ref);
      if (!unique) {
        newTitleError = 'The title is already taken';
      }
    }

    if (description.trim().isNotEmpty && description.trim().length < 3) {
      newDescError = 'Description must be empty or at least 3 characters';
    }

    return{
      'title':newTitleError,
      'description': newDescError,
    };
  }


}