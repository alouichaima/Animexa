import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart';

class VeterinarianListPage extends StatelessWidget {
  const VeterinarianListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Vétérinaires'),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'veterinaire')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement des vétérinaires.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final veterinarians = snapshot.data!.docs;

          return ListView.builder(
            itemCount: veterinarians.length,
            itemBuilder: (context, index) {
              var veterinarianData = veterinarians[index].data() as Map<String, dynamic>;
              LocalUser veterinarian = LocalUser.fromMap(veterinarianData);

              return ListTile(
                title: Text(veterinarian.username),
                subtitle: Text('${veterinarian.email} - ${veterinarian.region}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text('Êtes-vous sûr de vouloir supprimer ce vétérinaire ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await FirebaseFirestore.instance.collection('users').doc(veterinarian.id).delete();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
