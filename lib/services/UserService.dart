import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  
  Future<String> getUsernameById(String ownerId) async {
    try {
      
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(ownerId).get();

      if (doc.exists) {
        
        LocalUser user = LocalUser.fromFirestore(doc);
        return user.username; 
      } else {
        return 'Unknown User'; 
      }
    } catch (e) {
      print('Error fetching user: $e');
      return 'Error';
    }
  }

  Future<String> getOwnerId() async {
    final user = _firebaseAuth.currentUser;
    return user != null ? user.uid : '';
  }
}
