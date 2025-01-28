import 'package:animexa/main.dart';
import 'package:animexa/model/user.dart';

class LocalData {
  // Méthode pour sauvegarder les données utilisateur localement
  static void saveUserData(LocalUser user) {
    if (box != null) {
      box!.put('user', user.toJson());
    } else {
      print('Erreur : La boîte de données est nulle.');
    }
  }

  // Méthode pour supprimer les données utilisateur
  static void removeUserData() {
    if (box != null) {
      box!.delete('user');
    } else {
      print('Erreur : La boîte de données est nulle.');
    }
  }

  // Méthode pour récupérer les données utilisateur
  static LocalUser? getUserData() {
    final userData = box?.get('user');
    return userData != null ? LocalUser.fromJson(userData) : null;
  }
}
