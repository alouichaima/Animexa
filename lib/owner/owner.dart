import 'package:animexa/owner/PetManagementPage.dart';
import 'package:animexa/owner/UpdateProfile.dart';
import 'package:animexa/owner/appointmentPage.dart';
import 'package:animexa/services/VetService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animexa/app_route.dart';
import '../model/user.dart';
import 'package:url_launcher/url_launcher.dart';


class Owner extends StatefulWidget {
  const Owner({Key? key}) : super(key: key);

  @override
  State<Owner> createState() => _OwnerState();
}

class _OwnerState extends State<Owner> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LocalUser? _localUser;
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final List<String> _services = [
    "Cat",
    "Dog",
    "Sheep",
    "Bird",
    "Hamster",
    "Turtle",
    "Monkey"
  ];
  final List<String> _serviceImages = [
    "images/cat.png",
    "images/dog.png",
    "images/sheep.png",
    "images/bird.png",
    "images/hamster.png",
    "images/turtle.png",
    "images/monkey.png"
  ];
  List<String> _filteredServices = [];
  final List<Map<String, dynamic>> _vets = [
    {
      "name": "Drh. Irene Jeanny",
      "specialty": "Veterinary Neurosurgery",
      "price": 25,
      "distance": 2.7
    }
  ];
  List<Map<String, dynamic>> _filteredVets = [];

  @override
  void initState() {
    super.initState();
    _fetchLocalUser();
    _filteredServices = _services;
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredServices = _services;
        _filteredVets = _vets;
      });
    } else {
      setState(() {
        _filteredServices = _services
            .where((service) =>
            service.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _filteredVets = _vets
            .where((vet) =>
        vet["name"].toLowerCase().contains(query.toLowerCase()) ||
            vet["specialty"].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _fetchLocalUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _localUser = LocalUser.fromMap(userDoc.data()!);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          Get.snackbar("Error", "User data not found.");
        }
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
      Get.snackbar("Error", "Unable to fetch user data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? const Text('Owner',
            style: TextStyle(color: Color.fromARGB(255, 59, 57, 57)))
            : Text(
          'Hello ${_localUser?.username ?? 'User'}',
          style: const TextStyle(
              color: Color.fromARGB(255, 79, 83, 85),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,
                color: Color.fromARGB(255, 79, 83, 85)),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [

              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildDonationBanner(),
              const SizedBox(height: 24),
              _buildServiceSection(),
              const SizedBox(height: 24),
              _buildVeterinarianList(),





            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 700,
      height: 60,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Category...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.purple),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: _filterSearchResults,
      ),
    );
  }

  Widget _buildDonationBanner() {
    return Container(
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 211, 165, 97),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
         const Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 30.0), 
            child: Text(
              "Your pet is your responsibility, take care of it!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  ],
),

          Positioned(
            right: -50,
            top: -60,
            child: SizedBox(
              width: 150,
              height: 150,
              child: Image.asset('images/C-and-D.png', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text("See All")),
          ],
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filteredServices.length,
            itemBuilder: (context, index) {
              String service = _filteredServices[index];
              String imagePath = _serviceImages[index];
              return _buildServiceItem(service, imagePath);
            },
          ),
        ),
      ],
    );
  }
  void makeCall(String phoneNumber) async {
    final Uri telUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunch(telUri.toString())) {
      await launch(telUri.toString());
    } else {
      print("Could not launch $phoneNumber");
    }
  }


  Widget _buildVeterinarianList() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Veterinarians",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 41, 40, 43),
          ),
        ),
      ),
      StreamBuilder<List<LocalUser>>(
        stream: VeterinarianService().getVeterinarians(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No veterinarians found.'));
          } else {
            final veterinarians = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: veterinarians.length,
              itemBuilder: (context, index) {
                final veterinarian = veterinarians[index];
                return _buildVeterinarianCard(veterinarian);
              },
            );
          }
        },
      )
    ]);
  }

  Widget _buildVeterinarianCard(LocalUser veterinarian) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
                veterinarian.profileImageUrl ?? 'default_image_url'),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  veterinarian.username,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 41, 40, 43)),
                ),
                const SizedBox(height: 5.0),
                _buildPhoneItem(
                  context,
                  Icons.phone,
                  veterinarian.tel,
                  veterinarian.tel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneItem(BuildContext context, IconData icon, String title, String? phoneNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            if (phoneNumber != null && phoneNumber.isNotEmpty) {
              makeCall(phoneNumber);  // Call the makeCall function
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Impossible d\'appeler ce numéro.')),
              );
            }
          },
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 4.0),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "Cliquez pour l'appeler.",
            style: TextStyle(color: Colors.red[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }






  Widget _buildServiceItem(String service, String imagePath) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          service,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
          
            Get.toNamed(AppRoutes.propPage);
            break;
          case 1:
          
            _navigateToManagePets();
            break;
          case 2:
          
            _navigateToAppointmentPage();
            break;
          case 3:
          
            _navigateToMyHomePage();
            break;
          case 4:
          
            _navigateToProfilePage();
            break;
        }
      },
      selectedItemColor: Colors.blue[800],
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'My Pets'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Appointments'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), label: 'Chatbot'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }


  void _signOut() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }


  void _navigateToManagePets() {
    Get.to(() => const PetManagementPage());
  }

  void _navigateToAppointmentPage() {
    Get.to(() => const AppointmentPage());
  }
  void _navigateToPetManagement() {
    Get.to(() => const PetManagementPage());
  }
  void _navigateToMyHomePage() {
    Get.toNamed(AppRoutes.myHomePage);
  }


  void _navigateToProfilePage() {
    Get.to(() => const UpdateProfile());
  }
}
