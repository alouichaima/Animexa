import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animexa/app_route.dart';
import 'package:animexa/owner/PetManagementPage.dart';
import 'package:animexa/owner/UpdateProfile.dart';
import 'package:animexa/owner/appointmentPage.dart';

class BasePage extends StatefulWidget {
  final Widget body;
  final int currentIndex;

  const BasePage({
    Key? key,
    required this.body,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  void _onNavigationTapped(int index) {
    switch (index) {
      case 0:
        Get.toNamed(AppRoutes.propPage);
        break;
      case 1:
        Get.to(() => const PetManagementPage());
        break;
      case 2:
        Get.to(() => const AppointmentPage());
        break;
      case 3:
        Get.toNamed(AppRoutes.myHomePage);
        break;
      case 4:
        Get.to(() => const UpdateProfile());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: _onNavigationTapped,
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
      ),
    );
  }
}
