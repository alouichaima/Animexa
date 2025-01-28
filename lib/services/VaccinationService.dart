
import 'package:animexa/model/vaccination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addVaccination(String petId, Vaccination vaccination) async {
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .add(vaccination.toJson());
  }

  Future<List<Vaccination>> getVaccinations(String petId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .get();
    return snapshot.docs
        .map((doc) => Vaccination.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }



}
