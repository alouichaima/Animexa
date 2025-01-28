import 'package:animexa/chatbot/themeNotifier.dart';
import 'package:animexa/chatbot/themes.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:animexa/app_route.dart';
import 'package:animexa/core/hive/open_box.dart';
import 'firebase_options.dart';

Box? box;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  try {
    box = await openBox('animexa');
  } catch (e) {
    print('Error opening Hive box: $e');
  }


  await initializeAwesomeNotifications();

  runApp(const ProviderScope(child: MyApp()));
}


Future<void> initializeAwesomeNotifications() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelKey: 'vaccine_notifications',
        channelName: 'Vaccine Notifications',
        channelDescription: 'Notifications for upcoming vaccines',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelKey: 'appointment_notifications',
        channelName: 'Appointment Reminders',
        channelDescription: 'Notification channel for appointment reminders',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic_channel_group',
        channelGroupName: 'Basic group',
      )
    ],
    debug: kDebugMode,
  );

  final isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider); 

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animexa',
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      darkTheme: darkMode,
      themeMode: themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white, 
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, 
            foregroundColor: Colors.white, 
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue, 
          ),
        ),
        
      ),
    );
  }
}
