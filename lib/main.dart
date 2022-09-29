import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:goplus_driver/pages/homePage.dart';
import 'package:goplus_driver/screens/IntroScreen.dart';
import 'package:goplus_driver/widget/theme_data.dart';

import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyApp();
  }

}


class _MyApp extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      title: "Go Plus Driver",
      home: AnimatedSplashScreen(
        nextScreen: IntroScreen(),
        duration: 2500,
        splash: "assets/icon/white-text.png",
        backgroundColor : Color(0xFFFFD80E),
      ),
    );
  }
}

