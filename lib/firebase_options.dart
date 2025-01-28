import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyBQFP1_Vc1KsuFJauBaETS-ql-1TNZw6OM",
      authDomain: "animexa-90bd0.firebaseapp.com",
      projectId: "animexa-90bd0",
      storageBucket: "animexa-90bd0.appspot.com",
      messagingSenderId: "712138062332",
      appId: "1:712138062332:web:7fec763a8943323a279a79");

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDliYnsPtreasesu0NW5h_KFcBf0ReGyKI',
    appId: '1:712138062332:android:99eda98de4b72fce279a79',
    messagingSenderId: '712138062332',
    projectId: 'animexa-90bd0',
    storageBucket: 'animexa-90bd0.appspot.com',
  );
}