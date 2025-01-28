import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/pet.dart';
import '../model/dossier.dart';

class DossierFormPage extends StatefulWidget {
  final Pet pet;

  const DossierFormPage({super.key, required this.pet});

  @override
  // ignore: library_private_types_in_public_api
  _DossierFormPageState createState() => _DossierFormPageState();
}

class _DossierFormPageState extends State<DossierFormPage> {
  final _formKey = GlobalKey<FormState>();
  String posologie = '';
  String medicaments = '';
  bool isSaving = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveDossier() async {
    setState(() {
      isSaving = true;
    });

    try {
      Dossier newDossier = Dossier(
        posologie: posologie,
        medicaments: medicaments,
      );

      await _firestore
          .collection('pets')
          .doc(widget.pet.id)
          .collection('dossiers')
          .add(newDossier.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical file successfully added')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medical file for ${widget.pet.nom}'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'dosage',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  posologie = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'could you please enter the dosage.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Medicaments',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  medicaments = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Could you please enter the Medicaments.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveDossier();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          backgroundColor: Colors.blue[800],
                          shadowColor: Colors.black54,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Add Medical file'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
