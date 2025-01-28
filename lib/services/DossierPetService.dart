import 'package:animexa/model/dossierPet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DossierPetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'dossierPets';

  
  Future<void> addDossierPet(DossierPet dossierPet) async {
    try {
      await _firestore.collection(collectionPath).add(dossierPet.toMap());
    } catch (e) {
      print("Erreur lors de l'ajout du dossier : $e");
    }
  }

  
  Future<List<DossierPet>> getAllDossierPets() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(collectionPath).get();
      return snapshot.docs
          .map((doc) => DossierPet.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des dossiers : $e");
      return [];
    }
  }

  
  Future<void> deleteDossierPet(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).delete();
    } catch (e) {
      print("Erreur lors de la suppression du dossier : $e");
    }
  }

  Future<DossierPet?> getDossierPetById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collectionPath).doc(id).get();
      if (doc.exists) {
        return DossierPet.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération du dossier par ID : $e");
      return null;
    }
  }

  
  Future<void> updateDossierPet(String id, DossierPet dossierPet) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(id)
          .update(dossierPet.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour du dossier : $e");
    }
  }
}
