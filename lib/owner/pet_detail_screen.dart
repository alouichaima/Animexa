import 'package:flutter/material.dart';
import '../model/pet.dart';
import 'pet_vaccination_screen.dart'; 

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.nom),
        backgroundColor: Colors.blue[800], 
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[800]!, 
              Colors.blue[600]!, 
              Colors.blue[400]!, 
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [
              0.0,
              0.5,
              1.0
            ], 
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    pet.imageUrl,
                    height: 200, 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Nom: ${pet.nom}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text('Âge: ${pet.age} ans',
                  style: const TextStyle(color: Colors.white)),
              Text('Race: ${pet.race}',
                  style: const TextStyle(color: Colors.white)),
              Text('Sexe: ${pet.sexe}',
                  style: const TextStyle(color: Colors.white)),
              Text('Poids: ${pet.poids} kg',
                  style: const TextStyle(color: Colors.white)),
              Text('Antécédents Médicaux: ${pet.antecedentsMedicaux}',
                  style: const TextStyle(color: Colors.white)),
              Text('Observations: ${pet.observations}',
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetVaccinationScreen(pet: pet),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.pink, // Pink for contrast
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Track Vaccination',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
