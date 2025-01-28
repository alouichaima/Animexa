import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/pet.dart';
import '../model/dossier.dart';

class ListeDossierPage extends StatelessWidget {
  final Pet pet;

  const ListeDossierPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dossiers Médicaux de ${pet.nom}'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pets')
            .doc(pet.id)
            .collection('dossiers')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No Medical file found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final dossiers = snapshot.data!.docs.map((doc) {
            return Dossier.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: dossiers.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final dossier = dossiers[index];
              return DossierTile(dossier: dossier);
            },
          );
        },
      ),
    );
  }
}

class DossierTile extends StatelessWidget {
  final Dossier dossier;

  const DossierTile({super.key, required this.dossier});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        title: Text(
          'Medical File',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dosage: ${dossier.posologie}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'Medicaments: ${dossier.medicaments}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
