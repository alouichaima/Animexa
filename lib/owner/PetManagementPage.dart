import 'package:animexa/owner/AddPetScreen.dart';
import 'package:animexa/owner/UpdatePetScreen.dart';
import 'package:animexa/services/PetService.dart';
import 'package:animexa/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/pet.dart';
import 'pet_detail_screen.dart';

class PetManagementPage extends StatelessWidget {
  const PetManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Management'),
        backgroundColor: Colors.blue[300],
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 253, 253, 253),
              Color.fromARGB(255, 199, 217, 235),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: PetCrudCard(),
        ),
      ),
    );
  }
}

class PetCrudCard extends StatefulWidget {
  const PetCrudCard({super.key});

  @override
  State<PetCrudCard> createState() => _PetCrudCardState();
}

class _PetCrudCardState extends State<PetCrudCard> {
  final PetService petService = PetService();
  final NotificationService notificationService =
      NotificationService(); 

  List<Pet> pets = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _fetchPets(); 
    searchController.addListener(_filterPets); 
  }

  Future<void> _fetchPets() async {
    final username = await getCurrentUserUsername();

    if (username != 'Username not found' &&
        username != 'User is not logged in' &&
        username != 'Error fetching username') {
      petService.fetchPetsByOwnerName(username).listen((fetchedPets) {
        setState(() {
          pets = fetchedPets;
          isLoading = false;
        });
      }, onError: (error) {
        print("Error fetching pets: $error");
        setState(() {
          isLoading = false;
        });
      });
    } else {
      print(username);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getCurrentUserUsername() async {
    final user = FirebaseAuth.instance.currentUser;

    
    if (user != null) {
      try {
        
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        
        final username = userDoc.get('username') as String?;
        if (username != null && username.isNotEmpty) {
          return username;
        } else {
          print("Username not set for the current user.");
          return 'Username not found';
        }
      } catch (error) {
        print("Error fetching username from Firestore: $error");
        return 'Error fetching username';
      }
    } else {
      print("User is not logged in.");
      return 'User is not logged in';
    }
  }

  void _filterPets() {
    final query = searchController.text.toLowerCase();
    setState(() {
      pets =
          pets.where((pet) => pet.nom.toLowerCase().contains(query)).toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterPets);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search pets...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: pet.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: pet.imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) {
                                    print("Error loading image: $error");
                                    return const CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: 35,
                                      child: Icon(Icons.error),
                                    );
                                  },
                                ),
                              )
                            : const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 35,
                                child: Icon(Icons.pets),
                              ),
                        title: Text(
                          pet.nom,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          'Age: ${pet.age}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdatePetScreen(pet: pet),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PetDetailScreen(pet: pet),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final newPet = await Navigator.push<Pet>(
              context,
              MaterialPageRoute(builder: (context) => const AddPetScreen()),
            );

            if (newPet != null) {
              setState(() {
                pets.add(newPet);
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[300],
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Add New Pet'),
        ),
      ],
    );
  }
}
