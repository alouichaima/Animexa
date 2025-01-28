import 'dart:async';
import 'package:animexa/app_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/hive/local_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
   
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _route();
      timer.cancel();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
   
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  Future<void> _route() async {
    Timer(const Duration(seconds: 2), () {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        print('*********************User Data: ${LocalData.getUserData()}');
        if (user == null) {
          Get.offNamed(AppRoutes.login);
          print('*********************User is currently signed out!');
        } else {
          String? role = LocalData.getUserData()?.role;
          print('*********************User Role: $role');
          switch (role) {
            case 'proprietaire':
              Get.offNamed(AppRoutes.propPage);
              break;
            case 'veterinaire':
              Get.offNamed(AppRoutes.vetPage);
              break;
            case 'admin':
              Get.offNamed(AppRoutes.adminPage);
              break;
            default:
              Get.offNamed(AppRoutes.login);
              print(
                  '*********************Role not recognized, navigating to login!');
          }
          print('*********************User is signed in!');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        key: _globalKey,
        body: Center(
            child: Stack(
          children: [
          
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("images/Animexa_Logo.png", height: 175),
                const SizedBox(height: 50),
                const CircularProgressIndicator(),
              ],
            ),
          ],
        )));
  }
}
