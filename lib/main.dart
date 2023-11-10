import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'ui/splash/splash.dart';

import 'controller/bind/home_page_bidding.dart';
import 'controller/bind/splash_page_bidding.dart';
import 'ui/home/home_page.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  HttpOverrides.global = new MyHttpOverrides();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sistema Cicero',
      initialRoute: '/splash',
      getPages: [
        GetPage(
            name: '/home',
            page: () => HomePage(),
            transition: Transition.fade,
            binding: HomePageBinding()),
        GetPage(
            name: '/splash',
            page: () => SplashPage(),
            transition: Transition.fade,
            binding: SplashPageBinding()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
