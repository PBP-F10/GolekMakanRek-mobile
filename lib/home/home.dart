import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/widgets/left_drawer.dart';
import '../userprofile/screens/user_profile_page.dart';
import 'package:golekmakanrek_mobile/wishlist/screens/wishlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'GolekMakanRek!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Center(
        child: CupertinoButton(
          color: Colors.grey,
          child: const Text("User Profile"), 
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserProfilePage()),
              );
          }
        ),
      ),
    );
  }
}