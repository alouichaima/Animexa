import 'package:flutter/material.dart';

class TextForm extends StatelessWidget {
  final String hinttext;
  final TextEditingController mycontroller;
  final bool isPassword;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const TextForm({
    super.key,
    required this.hinttext,
    required this.mycontroller,
    this.isPassword = false,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: mycontroller,
      obscureText: isPassword ? obscureText : false, // Gestion de l'affichage du texte
      decoration: InputDecoration(
        hintText: hinttext,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color.fromARGB(255, 184, 184, 184)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        suffixIcon: suffixIcon, // Icône pour basculer la visibilité
      ),
      validator: validator,
    );
  }
}
