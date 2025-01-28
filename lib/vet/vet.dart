import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animexa/app_route.dart';
import '../model/pet.dart';

class Vet extends StatefulWidget {
  const Vet({super.key});

  @override
  State<Vet> createState() => _VetState();
}

class _VetState extends State<Vet> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _profileImageUrl = '';
  String _username = '';
  String _email = '';
  bool _isLoading = true;
  int _currentIndex = 3; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _username = userDoc['username'] ?? 'Unknown';
            _email = currentUser.email ?? 'No Email';
            _profileImageUrl = userDoc['profileImageUrl'] ?? '';
            _isLoading = false;
          });
        } else {
          print("User document not found.");
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  void _navigateToVaccinationSchedule() {
    Get.toNamed(AppRoutes.vaccinationPage);
  }

  void _navigateToDossierSchedule() {
    Get.toNamed(AppRoutes.dossierPage);
  }

void _navigateToDossierPetsSchedule() {
    Get.toNamed(AppRoutes.listedossierPet);
  }
  void _navigateToListVaccination(String petId) {
    if (petId.isEmpty) {
      Get.snackbar("Error", "Invalid Pet ID");
      return;
    }
    Get.toNamed('${AppRoutes.vaccinationListPage}/$petId');
  }

  void _navigateToProfileEdit() {
    Get.toNamed(AppRoutes.updateProfile);
  }
  

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print("Error during sign out: $e");
      Get.snackbar("Error", "Sign-out failed.");
    }
  }

  void _pickImage() {
    print('Pick an image...');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Veterinarian Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 20),
          // Profile Photo
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : const AssetImage('assets/placeholder.png')
                as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Name and email
          Text(
            _username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                const Divider(height: 40),
                _buildMenuOption(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  subtitle: 'Personalize Your Profile',
                  onTap: _navigateToProfileEdit,
                ),
                _buildMenuOption(
                  icon: Icons.vaccines,
                  title: 'Plan Vaccinations',
                  subtitle: 'Schedule vaccinations for each animal',
                  onTap: _navigateToVaccinationSchedule,
                ),
                _buildMenuOption(
                  icon: Icons.folder,
                  title: 'Folders',
                  subtitle: 'Show Some folders!',
                  onTap: _navigateToDossierSchedule,
                ),
                 _buildMenuOption(
                  icon: Icons.folder,
                  title: 'New pet\'s folder',
                  subtitle: 'Show Some folders!',
                  onTap: _navigateToDossierPetsSchedule,
                ),
                _buildMenuOption(
                  icon: Icons.local_hospital,
                  title: 'track vaccination',
                  subtitle: 'Show list vaccinations',
                  onTap: () {
                    String petId = 'your_dynamic_pet_id';
                    _navigateToListVaccination(petId);
                  },
                ),
                _buildMenuOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Securely Log Out of Account',
                  onTap: _signOut,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
          ),
        ],
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
            label: 'Folders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Profile',
          ),
           
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.blue[50],
        child: Icon(
          icon,
          color: Colors.blue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.blue,
      ),
      onTap: onTap,
    );
  }


}
