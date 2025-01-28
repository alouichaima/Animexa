import 'package:animexa/model/pet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdatePetScreen extends StatefulWidget {
  final Pet pet;

  const UpdatePetScreen({super.key, required this.pet});

  @override
  _UpdatePetScreenState createState() => _UpdatePetScreenState();
}

class _UpdatePetScreenState extends State<UpdatePetScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _raceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _sexeController;
  late TextEditingController _poidsController;
  late TextEditingController _antecedentsController;
  late TextEditingController _observationsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.nom);
    _ageController = TextEditingController(text: widget.pet.age.toString());
    _raceController = TextEditingController(text: widget.pet.race);
    _imageUrlController = TextEditingController(text: widget.pet.imageUrl);
    _sexeController = TextEditingController(text: widget.pet.sexe);
    _poidsController = TextEditingController(text: widget.pet.poids.toString());
    _antecedentsController =
        TextEditingController(text: widget.pet.antecedentsMedicaux);
    _observationsController =
        TextEditingController(text: widget.pet.observations);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _raceController.dispose();
    _imageUrlController.dispose();
    _sexeController.dispose();
    _poidsController.dispose();
    _antecedentsController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _updatePet() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('pets')
            .doc(widget.pet.id)
            .update({
          'nom': _nameController.text,
          'age': int.parse(_ageController.text),
          'race': _raceController.text,
          'imageUrl': _imageUrlController.text,
          'sexe': _sexeController.text,
          'poids': double.parse(_poidsController.text),
          'antecedentsMedicaux': _antecedentsController.text,
          'observations': _observationsController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet updated successfully')),
        );
        Navigator.pop(context); 
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update pet: $error')),
        );
      }
    }
  }

  Future<void> _deletePet() async {
    try {
      await FirebaseFirestore.instance
          .collection('pets')
          .doc(widget.pet.id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet deleted successfully')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete pet: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Pet'),
        backgroundColor: Colors.blue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              _buildTextField(_nameController, 'Name', TextInputType.text),
              const SizedBox(height: 15),
              _buildTextField(
                  _ageController, 'Age', TextInputType.number, true),
              const SizedBox(height: 15),
              _buildTextField(_raceController, 'Race', TextInputType.text),
              const SizedBox(height: 15),
              _buildTextField(
                  _imageUrlController, 'Image URL', TextInputType.url),
              const SizedBox(height: 15),
              _buildTextField(_sexeController, 'Sexe', TextInputType.text),
              const SizedBox(height: 15),
              _buildTextField(
                  _poidsController, 'Poids', TextInputType.number, true),
              const SizedBox(height: 15),
              _buildTextField(_antecedentsController, 'Antécédents Médicaux',
                  TextInputType.text),
              const SizedBox(height: 15),
              _buildTextField(
                  _observationsController, 'Observations', TextInputType.text),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _updatePet,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blue[300], 
                ),
                child: const Text(
                  'Update Pet',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _deletePet,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueGrey[600], 
                ),
                child: const Text(
                  'Delete Pet',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildTextField(TextEditingController controller, String labelText,
      TextInputType keyboardType,
      [bool isNumeric = false]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        if (isNumeric && double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
