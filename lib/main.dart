import 'package:flutter/material.dart';
import 'package:location/auth/signin.dart';
import 'package:location/auth/signup.dart';
import 'package:location/constants/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location/page/groups.dart';
import 'package:location/page/splashscreen.dart';
import 'package:location/page/home.dart';
import 'package:location/page/search.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Color(0xff71ccff),
          backgroundColor: Color(0xffe7ebf0),
        ),
        initialRoute: SPLASH_SCREEN,
        routes: {
          SIGN_IN: (context) => Signinpage(title: "sign in"),
          SIGN_UP: (context) => Signuppage(title: "sign up"),
          SPLASH_SCREEN: (context) => SplashScreen(),
          HOME_SCREEN: (context) => Home(),
          GROUP: (context) => Groups(),
          SEARCH: (context) => Search(),
        });
  }
}
