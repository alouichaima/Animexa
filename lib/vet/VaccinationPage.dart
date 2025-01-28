import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_route.dart';
import '../model/pet.dart';
import '../services/PetService.dart';
import '../services/UserService.dart';
import 'VaccinationFormPage.dart';

class VaccinationPage extends StatefulWidget {
  const VaccinationPage({super.key});

  @override
  _VaccinationPageState createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
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
        title: Row(
          children: [
            Icon(Icons.vaccines, color: Colors.white), // Add an icon
            const SizedBox(width: 10),
            const Text(
              'Plan Vaccinations',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

      // BottomNavigationBar
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: pet.imageUrl.isNotEmpty
              ? NetworkImage(pet.imageUrl)
              : const AssetImage('assets/pet_placeholder.png') as ImageProvider,
          backgroundColor: Colors.grey[200],
        ),
        title: Text(
          pet.nom,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Owner: ${pet.ownerName?.isNotEmpty == true ? pet.ownerName : 'Unknown'}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.vaccines_rounded,
            color: Colors.green,
            size: 28,
          ),
          tooltip: 'Schedule Vaccination',
          onPressed: () => _scheduleVaccination(pet),
        ),
      ),
    );
  }

  void _scheduleVaccination(Pet pet) {
    Get.to(() => VaccinationFormPage(pet: pet));
  }

}
