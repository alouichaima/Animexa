import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animexa/app_route.dart';
import 'package:animexa/components/buttonauth.dart';
import 'package:animexa/components/logoauth.dart';
import 'package:animexa/components/textform.dart' as CustomTextFieldPackage;
import '../core/firebase_store.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController region = TextEditingController();
  final TextEditingController tel = TextEditingController();
  bool _obscureText = true; 

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    region.dispose();
    tel.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );

        await FirebaseStore.addUserDataToFireStore(
          userId: userCredential.user!.uid,
          email: email.text,
          username: username.text,
          region: region.text,
          phone: tel.text,
          role: 'proprietaire',
        );

        await userCredential.user!.sendEmailVerification();

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          showCloseIcon: true,
          closeIcon: const Icon(Icons.close_fullscreen_outlined),
          title: 'Success',
          desc:
          'Registration successful! Please check your email to confirm your account.',
        ).show();

        await Future.delayed(const Duration(seconds: 2));
        Get.offAndToNamed(AppRoutes.login);
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already in use.';
            break;
          case 'weak-password':
            errorMessage = 'Password should be at least 6 characters.';
            break;
          default:
            errorMessage = 'Failed to register. Please try again.';
        }
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          showCloseIcon: true,
          closeIcon: const Icon(Icons.close_fullscreen_outlined),
          title: 'Error',
          desc: errorMessage,
        ).show();
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
              Color.fromARGB(255, 187, 217, 241),
              Colors.white,
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
                    "Username",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFieldPackage.TextForm(
                    hinttext: "Enter your username.",
                    mycontroller: username,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "E-mail",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFieldPackage.TextForm(
                    hinttext: "Enter your e-mail.",
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
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Region",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFieldPackage.TextForm(
                    hinttext: "Enter your region",
                    mycontroller: region,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Telephone",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFieldPackage.TextForm(
                    hinttext: "Enter your phone number",
                    mycontroller: tel,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ButtonAuth(
                title: "Register",
                onPressed: _submit,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Get.toNamed('/login');
                },
                child: const Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Already have an account? ",
                        ),
                        TextSpan(
                          text: "Login",
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
