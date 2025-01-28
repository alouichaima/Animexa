import 'package:flutter/material.dart';

class LogoAuth extends StatelessWidget {
  const LogoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          alignment: Alignment.center,
          width: 210,
          height: 210,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color.fromARGB(253, 255, 255, 255),
              borderRadius: BorderRadius.circular(90)),
          child: Image.asset(
            "images/Animexa_Logo.png",
            height: 210,
          )),
    );
  }
}
