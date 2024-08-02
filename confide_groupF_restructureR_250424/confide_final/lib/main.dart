import 'package:confide/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confide/theme.dart';
import 'package:get/get.dart';
import 'package:confide/conference/video_call_screen.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) async {
    try {
      await Firebase.initializeApp();
      runApp(const MyApp());
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ConfideApp',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        '/video-call': (context) => const VideoCallScreen(),
      },
      theme: myTheme,
      home: const SplashScreenTwo(),

      // home: const WelcomeScreen(),
    );
  }
}
