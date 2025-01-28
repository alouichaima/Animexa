import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:animexa/app_route.dart';
import 'package:animexa/core/hive/local_data.dart';
import 'package:animexa/components/textform.dart' as CustomTextFieldPackage;
import '../components/buttonauth.dart';
import '../components/logoauth.dart';
import '../model/user.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; 
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );

        if (userCredential.user != null && userCredential.user!.emailVerified) {
          
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          final userData = userDoc.data();

          
          if (userData != null &&
              userData.containsKey('role') &&
              userData.containsKey('username') &&
              userData.containsKey('email') &&
              userData.containsKey('region') &&
              userData.containsKey('tel')) {
            String userId = userCredential.user!.uid; 
            String userRole = userData['role'] as String;
            String userUsername = userData['username'] as String;
            String userEmail = userData['email'] as String;
            String userRegion = userData['region'] as String;
            String userTel = userData['tel'] as String;

            
            LocalUser localUser = LocalUser(
              id: userId,
              role: userRole,
              username: userUsername,
              email: userEmail,
              region: userRegion,
              tel: userTel,
            );

            
            LocalData.saveUserData(localUser);

            
            if (userRole == 'proprietaire') {
              Get.offAllNamed(AppRoutes.propPage);
            } else if (userRole == 'veterinaire') {
              Get.offAllNamed(AppRoutes.vetPage);
            } else {
              Get.offAllNamed(AppRoutes.adminPage);
            }
          } else {
            
            String missingFields = '';
            if (userData == null) {
              missingFields =
                  'Aucune donnée utilisateur trouvée dans Firestore.';
            } else {
              List<String> requiredFields = [
                'role',
                'username',
                'email',
                'region',
                'tel'
              ];
              List<String> missing = requiredFields
                  .where((field) => !userData.containsKey(field))
                  .toList();
              if (missing.isNotEmpty) {
                missingFields =
                    'Les champs suivants sont manquants dans Firestore : ${missing.join(', ')}.';
              }
            }

            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              showCloseIcon: true,
              closeIcon: const Icon(Icons.close_fullscreen_outlined),
              title: 'Erreur',
              desc: missingFields.isNotEmpty
                  ? missingFields
                  : 'Données utilisateur manquantes.',
            ).show();
          }
        } else {
          await FirebaseAuth.instance.currentUser!.sendEmailVerification();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            showCloseIcon: true,
            closeIcon: const Icon(Icons.close_fullscreen_outlined),
            title: 'Info',
            desc:
                "Veuillez vérifier votre boîte de réception et confirmer votre e-mail pour activer votre compte.",
          ).show();
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Adresse e-mail invalide.';
            break;
          case 'wrong-password':
            errorMessage = 'Mot de passe incorrect.';
            break;
          case 'user-disabled':
            errorMessage = 'Ce compte utilisateur a été désactivé.';
            break;
          case 'too-many-requests':
            errorMessage =
                'Trop de tentatives de connexion. Veuillez réessayer plus tard.';
            break;
          default:
            errorMessage = 'Échec de la connexion. Veuillez réessayer.';
        }

        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          showCloseIcon: true,
          closeIcon: const Icon(Icons.close_fullscreen_outlined),
          title: 'Erreur',
          desc: errorMessage,
        ).show();
      } catch (e) {
        print(e);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          showCloseIcon: true,
          closeIcon: const Icon(Icons.close_fullscreen_outlined),
          title: 'Erreur',
          desc: 'Une erreur inconnue s\'est produite.',
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
      body: Container(
        decoration: const BoxDecoration(
          
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 89, 173, 241), 
              Color.fromARGB(255, 187, 217, 241), // Bleu mixte
              Colors.white, // Blanc
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, 
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 50),
                  const LogoAuth(),
                  const SizedBox(height: 10),
                  const Text(
                    "E-mail",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFieldPackage.TextForm(
                    hinttext: "ُEnter your e-mail.",
                    mycontroller: email,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFieldPackage.TextForm(
                    isPassword: true,
                    hinttext: "Enter your password",
                    mycontroller: password,
                    obscureText: _obscureText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText; 
                        });
                      },
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Cannot be empty.";
                      } else if (val.length < 6) {
                        return "The password must be at least 6 characters long.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      if (email.text.isNotEmpty) {
                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email.text);

                          
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.rightSlide,
                            showCloseIcon: true,
                            closeIcon:
                                const Icon(Icons.close_fullscreen_outlined),
                            title: 'Success',
                            desc: 'Check your inbox to reset your password.',
                          ).show();
                        } catch (e) {
                          
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            showCloseIcon: true,
                            closeIcon:
                                const Icon(Icons.close_fullscreen_outlined),
                            title: 'Error',
                            desc:
                                'Failed to send the password reset email. Please try again',
                          ).show();
                        }
                      } else {
                        
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.rightSlide,
                          showCloseIcon: true,
                          closeIcon:
                              const Icon(Icons.close_fullscreen_outlined),
                          title: 'Warning.',
                          desc: 'Please enter your email first.',
                        ).show();
                      }
                    },
                    child: Container(
                      alignment: Alignment.topRight,
                      child: const Text(
                        "Forgot password ?",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ButtonAuth(
                title: _isLoading ? "Connexion..." : "Connexion",
                onPressed: _isLoading
                    ? null
                    : _login, 
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Get.toNamed('/register'); 
                },
                child: const Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have an account yet ?",
                        ),
                        TextSpan(
                          text: " Register",
                          style: TextStyle(
                            color: Color.fromARGB(255, 96, 99, 248),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
