import 'package:animexa/vet/track_vaccination.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_route.dart';
import '../model/pet.dart';
import '../services/PetService.dart';
import '../services/UserService.dart';
import 'VaccinationFormPage.dart';

class VaccinationListPage extends StatefulWidget {
  const VaccinationListPage({super.key});

  @override
  _VaccinationListPageState createState() => _VaccinationListPageState();
}

class _VaccinationListPageState extends State<VaccinationListPage> {
  final PetService petService = PetService();
  final UserService userService = UserService();
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Track Vaccinations',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: StreamBuilder<List<Pet>>(
        stream: petService.getPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No pets available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final pet = snapshot.data![index];
              return PetTile(pet: pet, userService: userService);
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        onTap: _onBottomNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vaccines, size: 28),
            label: 'Vaccination',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital, size: 28),
            label: 'Track Vaccination',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder, size: 28),
            label: 'Dossiers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          Get.toNamed(AppRoutes.vetPage);
          break;
        case 1:
          Get.toNamed(AppRoutes.vaccinationPage);
          break;
        case 2:
          Get.toNamed(AppRoutes.vaccinationListPage);
          break;
        case 3:
          Get.toNamed(AppRoutes.dossierPage);
          break;
        case 4:
          Get.toNamed(AppRoutes.vetProfileUpdate);
          break;
      }
    });
  }
}

class PetTile extends StatelessWidget {
  final Pet pet;
  final UserService userService;

  const PetTile({super.key, required this.pet, required this.userService});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        leading: CircleAvatar(
          radius: 35,
          backgroundImage: pet.imageUrl.isNotEmpty
              ? NetworkImage(pet.imageUrl)
              : const AssetImage('assets/pet_placeholder.png') as ImageProvider,
          backgroundColor: Colors.grey[200],
        ),
        title: Text(
          pet.nom,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Owner: ${pet.ownerName?.isNotEmpty == true ? pet.ownerName : 'Unknown'}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.local_hospital,
            color: Colors.green,
            size: 30,
          ),
          tooltip: 'Track Vaccination',
          onPressed: () => _trackvaccination(pet),
        ),
      ),
    );
  }

  void _trackvaccination(Pet pet) {
    Get.to(() => Track_vaccination(pet: pet));
  }
}
