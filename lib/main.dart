import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:goplus_driver/screens/checkPage.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:goplus_driver/utils/class_builder.dart';
import 'package:goplus_driver/utils/global_variables.dart';
import 'package:goplus_driver/widget/theme_data.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ClassBuilder.registerClasses();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=> Auth())
        ],
        child: MyApp(),
      )
  );

  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.black
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      title: "Go Plus Driver",
      builder: EasyLoading.init(),
      home: AnimatedSplashScreen(
        nextScreen: CheckPage(),
        duration: 2500,
        splash: "assets/icon/white-text.png",
        backgroundColor : const Color(0xFFFFD80E),
      ),
    );
  }
}

