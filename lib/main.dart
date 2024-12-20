import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:golekmakanrek_mobile/homepage/screens/splash_screen.dart';
import 'homepage/screens/main_screen.dart';
import 'package:golekmakanrek_mobile/authentication/login.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'GolekMakanRek!',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepOrange,
          ).copyWith(secondary: Colors.deepOrange[400]),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(
          nextScreen: LoginPage(),
        ),
      ),
    );
  }
}