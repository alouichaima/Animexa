import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseStore {
  static final firebaseFirestore = FirebaseFirestore.instance;

  // Method to add user data to Firestore
  static Future<void> addUserDataToFireStore({
    required String email,
    required String username,
    required String role,
    required String userId,
    required String phone,
    required String region,
  }) async {
    CollectionReference ref = firebaseFirestore.collection('users');
    await ref.doc(userId).set({
      'id': userId,
      'email': email,
      'role': role,
      'username': username,
      'tel': phone,
      'region': region,
    });
  }

  // Method to retrieve user data from Firestore
  static Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot snapshot =
        await firebaseFirestore.collection('users').doc(userId).get();
    return snapshot.data() as Map<String, dynamic>;
  }
}
