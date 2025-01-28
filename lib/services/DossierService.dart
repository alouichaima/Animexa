
import 'package:animexa/model/dossier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DossierService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 
  Future<void> addDossier(String petId, Dossier dossier) async {
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('dossiers')
        .add(dossier.toJson());
  }

  
  Future<List<Dossier>> getDossiers(String petId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('pets')
        .doc(petId)
        .collection('dossiers')
        .get();
    return snapshot.docs
        .map((doc) => Dossier.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
