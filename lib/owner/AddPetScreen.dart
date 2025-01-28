import 'dart:typed_data'; // Import for Uint8List
import 'package:animexa/model/pet.dart';
import 'package:animexa/services/petService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/hive/local_data.dart';
import '../model/user.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final PetService petService = PetService();
  final ImagePicker _picker = ImagePicker();

  String nom = '';
  int age = 0;
  String race = '';
  String imageUrl = ''; 
  String sexe = 'Mâle'; 
  double poids = 0.0;
  String antecedentsMedicaux = '';
  String observations = '';
  Uint8List? _selectedImage; 
  bool _isLoading = false; 
  LocalUser? currentUser;
  String? ownerName;

  @override
  void initState() {
    super.initState();
    currentUser = LocalData.getUserData();
    ownerName =
        currentUser!.username; 
    print(currentUser);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      
      final Uint8List bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = bytes; 
        imageUrl = image.path; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[300]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pet informations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets, color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your pet name';
                        }
                        return null;
                      },
                      onSaved: (value) => nom = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake, color: Colors.blue),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your pet age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number of pet age';
                        }
                        return null;
                      },
                      onSaved: (value) => age = int.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Race',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fingerprint, color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter you pet race';
                        }
                        return null;
                      },
                      onSaved: (value) => race = value!,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: sexe,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.transgender, color: Colors.blue),
                      ),
                      items: ['Mâle', 'Femelle']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          sexe = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a gender from the list';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'weight',
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.fitness_center, color: Colors.blue),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the weight';
                        }
                        return null;
                      },
                      onSaved: (value) => poids = double.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Medical History',
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.medical_services, color: Colors.blue),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Medical History of your pet';
                        }
                        return null;
                      },
                      onSaved: (value) => antecedentsMedicaux = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Observations',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes, color: Colors.blue),
                      ),
                      maxLines: 4,
                      onSaved: (value) => observations = value!,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 137, 190, 237),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _pickImage,
                      child: const Text(
                        'Upload image',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _selectedImage!, 
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 137, 190, 237),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedImage == null) {
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select an image.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                _formKey.currentState!
                                    .save(); 

                                
                                final newAnimal = Pet(
                                  
                                  nom: nom,
                                  age: age,
                                  race: race,
                                  imageUrl:
                                      imageUrl, 
                                  sexe: sexe,
                                  poids: poids,
                                  antecedentsMedicaux: antecedentsMedicaux,
                                  observations: observations,
                                  ownerName: ownerName ?? '',
                                );

                                setState(() {
                                  _isLoading = true; 
                                });

                                try {
                                  
                                  await petService.addPet(
                                      newAnimal, _selectedImage);
                                  Navigator.pop(
                                      context);
                                } catch (error) {
                                  
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text(
                                          'error occurred during the addition of the animal'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Close'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false; 
                                  });
                                }
                              }
                            },
                            child: const Text(
                              'Add Pet',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
