import 'package:animexa/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VeterinarianService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addVeterinarian(LocalUser veterinarian) async {
    try {
      
      await _firestore.collection('users').doc(veterinarian.id).set({
        'username': veterinarian.username,
        'email': veterinarian.email,
        'region': veterinarian.region,
        'tel': veterinarian.tel,
        'role': veterinarian.role,
      });
    } catch (e) {
      print('Error adding veterinarian to Firestore: $e');
    }
  }

  
  Stream<List<LocalUser>> getVeterinarians() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'veterinaire')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LocalUser.fromFirestore(doc);
      }).toList();
    });
  }

  Future<DocumentReference> createAppointment(
      Map<String, dynamic> appointmentData) async {
    
    CollectionReference appointments =
        FirebaseFirestore.instance.collection('appointments');

    
    return await appointments.add(appointmentData);
  }
}
