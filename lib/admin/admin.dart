import 'dart:io';
import 'package:animexa/admin/VeterinarianList.dart';
import 'package:animexa/admin/addVet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _profileImageUrl = '';
  String _username = '';
  String _email = '';
  bool _isLoading = true;
  File? _imageFile;
  late final Stream<QuerySnapshot> usersStream;
  late final Stream<QuerySnapshot> petsStream;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    
    usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    petsStream = FirebaseFirestore.instance.collection('pets').snapshots();
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

  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      
      _uploadImageToFirebase();
    }
  }

  
  Future<void> _uploadImageToFirebase() async {
    if (_imageFile != null) {
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          String fileName = 'profile_${currentUser.uid}.jpg';
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child(fileName);

      
          UploadTask uploadTask = storageRef.putFile(_imageFile!);
          TaskSnapshot snapshot = await uploadTask;

          
          String downloadUrl = await snapshot.ref.getDownloadURL();

          
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({'profileImageUrl': downloadUrl});

          setState(() {
            _profileImageUrl = downloadUrl;
          });

          print("Image téléchargée avec succès: $downloadUrl");
        }
      } catch (e) {
        print("Erreur lors de l'upload de l'image: $e");
      }
    }
  }

  
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      print("Erreur lors de la déconnexion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          
          Container(
            height: 300, 
            decoration: BoxDecoration(
              color: Colors.blue[800],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profileImageUrl.isNotEmpty
                      ? NetworkImage(_profileImageUrl)
                      : null,
                  child: _profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                // Username and Email
                Text(
                  _username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 7),
                
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Upload Photo'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add a Veterinarian'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const AddVeterinarianByAdmin());
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('List of Veterinarians'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const VeterinarianListPage());
            },
          ),
        ],
      ),
    );
  }

  
  Widget _buildStatistics() {
    return StreamBuilder<QuerySnapshot>(
      stream: usersStream,
      builder: (context, usersSnapshot) {
        if (!usersSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var userDocs = usersSnapshot.data?.docs ?? [];
        int totalUsers = userDocs.length;
        int totalOwners =
            userDocs.where((doc) => doc['role'] == 'proprietaire').length;
        int totalAdmins =
            userDocs.where((doc) => doc['role'] == 'admin').length;

        return StreamBuilder<QuerySnapshot>(
          stream: petsStream,
          builder: (context, petsSnapshot) {
            if (!petsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            int totalPets = petsSnapshot.data?.docs.length ?? 0;

            double ownerPercentage =
                totalOwners > 0 ? (totalPets / totalOwners) * 100 : 0;
            double remainingPercentage = 100 - ownerPercentage;

            double userRolePercentage = totalUsers > 0
                ? (totalUsers - totalOwners - totalAdmins) / totalUsers * 100
                : 0;
            double ownerRolePercentage =
                totalUsers > 0 ? totalOwners / totalUsers * 100 : 0;
            double adminRolePercentage =
                totalUsers > 0 ? totalAdmins / totalUsers * 100 : 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPieChart(
                  'Pets vs Owners',
                  ownerPercentage,
                  remainingPercentage,
                  Colors.blue,
                  Colors.orange,
                ),
                const SizedBox(height: 40),
                _buildPieChart(
                  'User Roles Distribution',
                  ownerRolePercentage,
                  userRolePercentage,
                  Colors.blue,
                  Colors.green,
                ),
                const SizedBox(height: 40),
                _buildSummary(totalOwners, totalPets, totalUsers, totalAdmins),
              ],
            );
          },
        );
      },
    );
  }

  /// Construire un graphique circulaire (PieChart)
  Widget _buildPieChart(
    String title,
    double value1,
    double value2,
    Color color1,
    Color color2,
  ) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: color1,
                    value: value1,
                    title: '${value1.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: color2,
                    value: value2,
                    title: '${value2.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
      int totalOwners, int totalPets, int totalUsers, int totalAdmins) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    _buildSummaryRow('Total Owners', totalOwners, Colors.blue),
                    _buildSummaryRow('Total Pets', totalPets, Colors.orange),
                    _buildSummaryRow('Total Veterinarian',
                        totalUsers - totalOwners - totalAdmins, Colors.green),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSummaryRow(String label, int value, Color color) {
    return Row(
      children: [
        Container(width: 20, height: 20, color: color),
        const SizedBox(width: 8),
        Text('$label: $value', style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
