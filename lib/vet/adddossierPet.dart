import 'package:animexa/model/dossierPet.dart';
import 'package:animexa/services/DossierPetService.dart';
import 'package:flutter/material.dart';

class AddDossierPet extends StatefulWidget {
  @override
  _AddDossierPetState createState() => _AddDossierPetState();
}

class _AddDossierPetState extends State<AddDossierPet> {
  final _formKey = GlobalKey<FormState>();

  
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _sexeController = TextEditingController();
  final TextEditingController _poidsController = TextEditingController();
  final TextEditingController _antecedentsController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  final TextEditingController _posologieController = TextEditingController();
  final TextEditingController _medicamentsController = TextEditingController();

  final DossierPetService _dossierPetService = DossierPetService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add pet'\s folder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your  pet\'s name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), 
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), 
              TextFormField(
                controller: _raceController,
                decoration: InputDecoration(labelText: 'Race'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s race';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), 
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image\'s URL'),
              ),
              SizedBox(height: 16), 
              TextFormField(
                controller: _sexeController,
                decoration: InputDecoration(labelText: 'Sexe'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s sexe';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), 
              TextFormField(
                controller: _poidsController,
                decoration: InputDecoration(labelText: 'weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s weight';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), 
              TextFormField(
                controller: _antecedentsController,
                decoration: InputDecoration(labelText: 'Medical History'),
              ),
              SizedBox(height: 16), 
              TextFormField(
                controller: _observationsController,
                decoration: InputDecoration(labelText: 'Observations'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _posologieController,
                decoration: InputDecoration(labelText: 'Dosage'),
              ),
              SizedBox(height: 16), 
              TextFormField(
                controller: _medicamentsController,
                decoration: InputDecoration(labelText: 'Medications'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                   
                    DossierPet newDossier = DossierPet(
                      nom: _nomController.text,
                      age: int.parse(_ageController.text),
                      race: _raceController.text,
                      imageUrl: _imageUrlController.text.isEmpty
                          ? ''
                          : _imageUrlController.text,
                      sexe: _sexeController.text,
                      poids: double.parse(_poidsController.text),
                      antecedentsMedicaux: _antecedentsController.text,
                      observations: _observationsController.text,
                      posologie: _posologieController.text,
                      medicaments: _medicamentsController.text,
                    );

                    await _dossierPetService.addDossierPet(newDossier);

                  
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Folder added successfully')),
                    );

                   
                    _formKey.currentState!.reset();
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
