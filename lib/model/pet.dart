import 'package:animexa/model/vaccination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String? id;
  final String nom;
  final int age;
  final String race;
  final String imageUrl;
  final String sexe;
  final double poids;
  final String antecedentsMedicaux;
  final String observations;
  final String? ownerName;
  final List<Vaccination> vaccinations;

  Pet({
    this.id,
    required this.nom,
    required this.age,
    required this.race,
    required this.imageUrl,
    required this.sexe,
    required this.poids,
    required this.antecedentsMedicaux,
    required this.observations,
    this.ownerName,
    this.vaccinations = const [],
  });

  Pet copyWith({
    String? nom,
    int? age,
    String? race,
    String? imageUrl,
    String? sexe,
    double? poids,
    String? antecedentsMedicaux,
    String? observations,
    String? ownerName,
  }) {
    return Pet(
      id: id,
      nom: nom ?? this.nom,
      age: age ?? this.age,
      race: race ?? this.race,
      imageUrl: imageUrl ?? this.imageUrl,
      sexe: sexe ?? this.sexe,
      poids: poids ?? this.poids,
      antecedentsMedicaux: antecedentsMedicaux ?? this.antecedentsMedicaux,
      observations: observations ?? this.observations,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'age': age,
      'race': race,
      'imageUrl': imageUrl,
      'sexe': sexe,
      'poids': poids,
      'antecedentsMedicaux': antecedentsMedicaux,
      'observations': observations,
      'ownerName': ownerName,
      'vaccinations': vaccinations
          .map((v) => v.toJson())
          .toList(), 
    };
  }

  static Pet fromMap(Map<String, dynamic> map, String id) {
    return Pet(
      id: map['id'] as String?,
      nom: map['nom'] as String,
      age: map['age'] as int,
      race: map['race'] as String,
      imageUrl: map['imageUrl'] as String,
      sexe: map['sexe'] as String,
      poids: (map['poids'] as num).toDouble(),
      antecedentsMedicaux: map['antecedentsMedicaux'] as String,
      observations: map['observations'] as String,
      ownerName: map['ownerName'] as String?,
      vaccinations: (map['vaccinations'] as List<dynamic>? ?? [])
          .map((vaccination) => Vaccination.fromMap(vaccination))
          .toList(),
    );
  }

  
  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      nom: data['nom'] ?? '',
      age: data['age'] ?? 0,
      race: data['race'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sexe: data['sexe'] ?? '',
      poids: (data['poids'] ?? 0).toDouble(),
      antecedentsMedicaux: data['antecedentsMedicaux'] ?? '',
      observations: data['observations'] ?? '',
      ownerName: data['ownerName'] ?? '',
      vaccinations: (data['vaccinations'] as List<dynamic>? ?? [])
          .map((vaccination) => Vaccination.fromMap(vaccination))
          .toList(),
    );
  }
}
