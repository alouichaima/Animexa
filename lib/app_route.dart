import 'package:animexa/admin/admin.dart';
import 'package:animexa/chatbot/myHomePage.dart';
import 'package:animexa/owner/appointmentListbyId.dart';
import 'package:animexa/owner/appointmentPage.dart';
import 'package:animexa/splash/splash_screen.dart';
import 'package:animexa/vet/DossierPage.dart';
import 'package:animexa/vet/UpdateVetProfile.dart';
import 'package:animexa/vet/VaccinationListPage.dart';
import 'package:animexa/vet/VaccinationPage.dart';
import 'package:animexa/vet/listedossierPet.dart';
import 'package:animexa/vet/vet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'admin/dash.dart';
import 'authentication/login.dart';
import 'authentication/register.dart';
import 'model/pet.dart';
import 'owner/UpdateProfile.dart';
import 'owner/owner.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String vetPage = '/vet';
  static const String propPage = '/owner';
  static const String adminPage = '/admin';
  static const String updateProfile = '/updateProfile';
  static const String vaccinationPage = '/vaccinations';
  static const String dossierPage = '/dossier';
  static const String vetProfileUpdate = '/updateVetProfile';
  static const String appointmentPage = '/appointmentPage';
  static const String appointmentListById = '/appointmentListById';
  static const String myHomePage = '/myHomePage';
  static const String listedossierPet = '/listedossierPet';
  static const String vaccinationListPage = '/vaccination_list';
  static const String reportsPage = '/ReportsPage';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const Login(),
    ),
    GetPage(
      name: adminPage,
      page: () => const Admin(),
    ),
    GetPage(
      name: vetPage,
      page: () => const Vet(),
    ),
    GetPage(
      name: propPage,
      page: () => const Owner(),
    ),
    GetPage(
      name: register,
      page: () => const Register(),
    ),
    GetPage(
      name: updateProfile,
      page: () => const UpdateProfile(),
    ),
    GetPage(
      name: vaccinationPage,
      page: () => const VaccinationPage(),
    ),
    GetPage(
      name: vetProfileUpdate,
      page: () => const UpdateVetProfile(),
    ),
    GetPage(
      name: appointmentPage,
      page: () => const AppointmentPage(),
    ),
    GetPage(
      name: appointmentListById,
      page: () => const AppointmentListById(),
    ),
    GetPage(
      name: dossierPage,
      page: () => const DossierPage(),
    ),
    GetPage(
      name: myHomePage,
      page: () => const MyHomePage(),
    ),
    GetPage(
      name: vaccinationListPage,
      page: () => const VaccinationListPage(),
    ),
    // Correction ici
    GetPage(
      name: listedossierPet,
      page: () => ListeDossierPet(),
    ),
    GetPage(
      name: reportsPage,
      page: () => ReportsPage(),
    ),
  ];
}
