import 'package:cloud_firestore/cloud_firestore.dart';

class DossierPet {
  String? id;
  final String nom;
  final int age;
  final String race;
  final String imageUrl;
  final String sexe;
  final double poids;
  final String antecedentsMedicaux;
  final String observations;
  final String posologie;
  final String medicaments;

  DossierPet({
    this.id,
    required this.nom,
    required this.age,
    required this.race,
    required this.imageUrl,
    required this.sexe,
    required this.poids,
    required this.antecedentsMedicaux,
    required this.observations,
    required this.posologie,
    required this.medicaments,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'age': age,
      'race': race,
      'imageUrl': imageUrl,
      'sexe': sexe,
      'poids': poids,
      'antecedentsMedicaux': antecedentsMedicaux,
      'observations': observations,
      'posologie': posologie,
      'medicaments': medicaments,
    };
  }

  // Convertir un document Firestore en DossierPet
  factory DossierPet.fromDocument(DocumentSnapshot doc) {
    return DossierPet(
      id: doc.id,
      nom: doc['nom'],
      age: doc['age'],
      race: doc['race'],
      imageUrl: doc['imageUrl'],
      sexe: doc['sexe'],
      poids: doc['poids'],
      antecedentsMedicaux: doc['antecedentsMedicaux'],
      observations: doc['observations'],
      posologie: doc['posologie'],
      medicaments: doc['medicaments'],
    );
  }

  factory DossierPet.fromMap(Map<String, dynamic> map) {
    return DossierPet(
      id: map['id'] ?? '', // Add default value if not present
      nom: map['nom'] ?? '',
      race: map['race'] ?? '',
      sexe: map['sexe'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      poids: (map['poids'] ?? 0).toDouble(),
      age: map['age'] ?? 0,
      antecedentsMedicaux: map['antecedentsMedicaux'] ?? '',
      observations: map['observations'] ?? '',
      posologie: map['posologie'] ?? '',
      medicaments: map['medicaments'] ?? '',
    );
  }
}
