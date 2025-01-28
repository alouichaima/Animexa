import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../app_route.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../model/user.dart';

class UpdateVetProfile extends StatefulWidget {
  const UpdateVetProfile({super.key});

  @override
  State<UpdateVetProfile> createState() => _UpdateVetProfileState();
}

 class _UpdateVetProfileState extends State<UpdateVetProfile> {
  LocalUser? _user;
  bool _isLoading = true;
  bool _isUpdating = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _telController;
  late TextEditingController _regionController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  XFile? _imageFile; 
  String? _uploadedImageUrl; 
  int _currentIndex = 2; 

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _user = LocalUser.fromMap(userDoc.data()!);
            _isLoading = false;

            _usernameController = TextEditingController(text: _user!.username);
            _emailController = TextEditingController(text: _user!.email);
            _telController = TextEditingController(text: _user!.tel);
            _regionController = TextEditingController(text: _user!.region);
            _uploadedImageUrl = _user!.profileImageUrl;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          Get.snackbar("Erreur", "Données utilisateur non trouvées.");
        }
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      print("Erreur lors de la récupération des données utilisateur: $e");
      setState(() {
        _isLoading = false;
      });
      Get.snackbar("Erreur", "Impossible de récupérer les données utilisateur.");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      print("Erreur lors de la sélection de l'image: $e");
      Get.snackbar("Erreur", "Impossible de sélectionner l'image.");
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      String userId = _auth.currentUser!.uid;
      Reference ref = _storage.ref().child('profile_images').child('$userId.jpg');

      UploadTask uploadTask = ref.putData(await image.readAsBytes());

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Erreur lors de l'upload de l'image: $e");
      Get.snackbar("Erreur", "Impossible de télécharger l'image.");
      return null;
    }
  }

  Future<void> _updateProfileAction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      try {
        User? user = _auth.currentUser;
        if (user != null) {
          String? imageUrl = _uploadedImageUrl;

          if (_imageFile != null) {
            imageUrl = await _uploadImage(_imageFile!);
          }

          Map<String, dynamic> updatedData = {
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'tel': _telController.text.trim(),
            'region': _regionController.text.trim(),
          };

          if (imageUrl != null) {
            updatedData['profileImageUrl'] = imageUrl;
          }

          await _firestore.collection('users').doc(user.uid).update(updatedData);

          if (_emailController.text.trim() != user.email) {
            await user.updateEmail(_emailController.text.trim());
          }

          Get.snackbar("Succès", "Profile updated successfully.");

          Get.offNamed(AppRoutes.propPage);
        } else {
          Get.snackbar("Erreur", "User not logged in.");
        }
      } catch (e) {
        print("Error updating profile: $e");
        Get.snackbar("Erreur", "Unable to update profile.");
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _regionController.dispose();
    super.dispose();
  }


  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: _imageFile != null
                ? FileImage(File(_imageFile!.path))
                : _uploadedImageUrl != null
                ? NetworkImage(_uploadedImageUrl!)
                : const AssetImage('images/default_profile.jpg'),
            onBackgroundImageError: (_, __) {
              
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _uploadedImageUrl = null;
                  });
                }
              });
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickImage,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.lightBlueAccent,

                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user != null
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 24.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Username
                  CustomTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Phone
                  CustomTextField(
                    controller: _telController,
                    labelText: 'Phone',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Region
                  CustomTextField(
                    controller: _regionController,
                    labelText: 'Region',
                    icon: Icons.map,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a region';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _isUpdating
                          ? const CircularProgressIndicator()
                          : Expanded(
                        child: CustomButton(
                          text: 'Save',
                          onPressed: _updateProfileAction,
                          icon: Icons.save,
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          onPressed: () {
                            
                            Get.offNamed(AppRoutes.propPage);
                          },
                          icon: Icons.cancel,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        ),

                      ),
                      const SizedBox(width: 16.0),

                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          : const Center(
        child: Text(
          "No user data available.",
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
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