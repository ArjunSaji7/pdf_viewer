import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:pdf_viewer/screens/home.dart';
import 'package:pdf_viewer/screens/screen_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await initializeFirebase();
  await FlutterDownloader.initialize(
    debug: true, // Set to false in production
    ignoreSsl: true, // Optional, for testing with self-signed URLs
  );


  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  const firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyAoRRf1JDHzIUWH84TZ0igj6UXigGwQ4rw',
    authDomain: 'travelbasecom.firebaseapp.com',
    projectId: 'travelbasecom',
    storageBucket: 'travelbasecom.appspot.com',
    messagingSenderId: '937267774107',
    appId: '1:937267774107:android:f4ec43ddf23476e4227c3e',
  );
  await Firebase.initializeApp(options: firebaseOptions);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  ScreenSplash(),
    );
  }
}
