import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

class Tricount{
  final int id;
  final String  titre;
  String descsription;
  final int creator;
  List<int> participants;
  final DateTime creation_date;
  
  Tricount({
    required this.id,
    required this.titre,
    this.descsription = "", //le rendre optionnel
    required this.creator,
    required this.participants,
    required this.creation_date
  });
  
  factory Tricount .formJson(Map<String, dynamic> json){
    return Tricount(
        id: json['id'], 
        titre: json['titre'], 
        creator: json['creator'], 
        participants: json['participants'], 
        creation_date: json['creation_date']);
  }       
  
  String get tricount_name => titre + descsription;
  
  String toString(){return '$id $titre $descsription';}
  
  String getTitle(){return this.titre;}
  
  String getDescription(){return this.descsription;}
  
  int getCreator(){return this.creator;}
  
  List<int> getParticipants(){return this.participants;} 
  
  DateTime getCreationDate(){return this.creation_date;}
  
}