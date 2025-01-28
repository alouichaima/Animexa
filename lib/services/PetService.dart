import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:animexa/model/pet.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  
  /// [pet] - The Pet object containing pet details.
  /// [imageBytes] - The image data in Uint8List format.
  Future<void> addPet(Pet pet, Uint8List? imageBytes) async {
    String imageUrl = '';

    if (imageBytes != null) {
      try {
        
        final imageRef = _storage.ref().child('pets/${pet.id}.jpg');

        
        await imageRef.putData(imageBytes);

        
        imageUrl = await imageRef.getDownloadURL();
      } catch (e) {
        
        print('Error uploading image: $e');
      }
    }

    try {
      
      await _firestore.collection('pets').doc(pet.id).set({
        'nom': pet.nom,
        'age': pet.age,
        'race': pet.race,
        'imageUrl': imageUrl,
        'sexe': pet.sexe,
        'poids': pet.poids,
        'antecedentsMedicaux': pet.antecedentsMedicaux,
        'observations': pet.observations,
        'ownerName': pet.ownerName,
      });
    } catch (e) {
      
      print('Error adding pet to Firestore: $e');
    }
  }

  Future<void> updatePet(Pet pet, Uint8List? imageBytes) async {
    String imageUrl = pet.imageUrl; 

    
    if (imageBytes != null) {
      try {
        final imageRef = _storage.ref().child('pets/${pet.id}.jpg');
        await imageRef.putData(imageBytes);
        imageUrl = await imageRef.getDownloadURL();
      } catch (e) {
        print('Error uploading updated image: $e');
      }
    }

    try {
      
      await _firestore.collection('pets').doc(pet.id).update({
        'nom': pet.nom,
        'age': pet.age,
        'race': pet.race,
        'imageUrl': imageUrl,
        'sexe': pet.sexe,
        'poids': pet.poids,
        'antecedentsMedicaux': pet.antecedentsMedicaux,
        'observations': pet.observations,
        'ownerName': pet.ownerName,
      });
    } catch (e) {
      print('Error updating pet in Firestore: $e');
    }
  }

  
  Stream<List<Pet>> getPets() {
    return _firestore.collection('pets').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Pet.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<List<Pet>> fetchPetsByOwnerName(String username) {
    return FirebaseFirestore.instance
        .collection('pets')
        .where('ownerName', isEqualTo: username) 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromFirestore(doc)) 
            .toList());
  }
}
