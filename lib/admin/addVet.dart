import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animexa/app_route.dart';
import 'package:animexa/components/buttonauth.dart';

import '../core/firebase_store.dart';

class AddVeterinarianByAdmin extends StatefulWidget {
  const AddVeterinarianByAdmin({super.key});

  @override
  State<AddVeterinarianByAdmin> createState() => _AddVeterinarianByAdminState();
}

class _AddVeterinarianByAdminState extends State<AddVeterinarianByAdmin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController region = TextEditingController();
  final TextEditingController tel = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    region.dispose();
    tel.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String temporaryPassword = "Temp123!"; 
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text,
          password: temporaryPassword,
        );

        await FirebaseStore.addUserDataToFireStore(
          userId: userCredential.user!.uid,
          email: email.text,
          username: username.text,
          region: region.text,
          phone: tel.text,
          role: 'veterinaire',
        );

        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          showCloseIcon: true,
          closeIcon: const Icon(Icons.close_fullscreen_outlined),
          title: 'Success',
          desc: 'Veterinarian added successfully! An email has been sent to reset their password.',
        ).show();

        await Future.delayed(const Duration(seconds: 2));

        Get.offAndToNamed(AppRoutes.adminPage);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            showCloseIcon: true,
            closeIcon: const Icon(Icons.close_fullscreen_outlined),
            title: 'Error',
            desc: 'An account already exists for this email.',
          ).show();
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            showCloseIcon: true,
            closeIcon: const Icon(Icons.close_fullscreen_outlined),
            title: 'Error',
            desc: 'An unknown error occurred. ${e.message}',
          ).show();
        }
      } catch (e) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          showCloseIcon: true,
          closeIcon: const Icon(Icons.close_fullscreen_outlined),
          title: 'Error',
          desc: 'An unknown error occurred.',
        ).show();
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Veterinarian'),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back(); 
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 145, 196, 238),
              Color.fromARGB(255, 187, 217, 241),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), 
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Add Veterinarian",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: username,
                  decoration: const InputDecoration(
                    hintText: "Enter veterinarian's name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter veterinarian\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Enter veterinarian's email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter veterinarian\'s email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: region,
                  decoration: const InputDecoration(
                    hintText: "Enter region",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter region';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: tel,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "Enter phone number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ButtonAuth(
                  title: "Add Veterinarian",
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
