import 'package:animexa/model/dossierPet.dart';
import 'package:animexa/services/DossierPetService.dart';
import 'package:animexa/vet/adddossierPet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeDossierPet extends StatefulWidget {
  @override
  _ListeDossierPetState createState() => _ListeDossierPetState();
}

class _ListeDossierPetState extends State<ListeDossierPet> {
  final DossierPetService _dossierPetService = DossierPetService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DossierPet>> getAllDossierPets() async {
    try {
      final querySnapshot = await _firestore.collection('dossierPet').get();
      return querySnapshot.docs
          .map((doc) => DossierPet.fromMap(doc.data())
            ..id = doc.id) 
          .toList();
    } catch (e) {
      throw Exception('Failed to load dossier pets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folder\'s List of Pets'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: FutureBuilder<List<DossierPet>>(
        future: _dossierPetService.getAllDossierPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No files found.'));
          } else {
            List<DossierPet> dossierList = snapshot.data!;
            return ListView.builder(
              itemCount: dossierList.length,
              itemBuilder: (context, index) {
                DossierPet dossier = dossierList[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: dossier.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              "https://www.trupanion.com/images/trupanionwebsitelibraries/pet-blogs/bengal-cat-1-.jpg?sfvrsn=4f56903_6",
                              width: 80,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.grey,
                                ); // Display a fallback icon if the image fails
                              },
                            ),
                          )
                        : Icon(
                            Icons.folder,
                            size: 80,
                            color: Colors.grey,
                          ),
                    title: Text(dossier.nom),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Age: ${dossier.age} years'),
                        Text('Breed: ${dossier.race}'),
                        Text('Weight: ${dossier.poids} kg'),
                        Text('Gender: ${dossier.sexe}'),
                        Text('Medical History: ${dossier.antecedentsMedicaux}'),
                        Text('Observations: ${dossier.observations}'),
                        Text('Dosage: ${dossier.posologie}'),
                        Text('Medications: ${dossier.medicaments}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDossierPet()),
          ).then((value) {
            
            setState(() {});
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Add Medical File',
      ),
    );
  }
}
