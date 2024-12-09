import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:golekmakanrek_mobile/homepage/screens/item_list.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: 'GolekMakanRek',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepOrange,
          ).copyWith(secondary: Colors.deepOrange[400]),
        ),
        home: const ItemList(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}