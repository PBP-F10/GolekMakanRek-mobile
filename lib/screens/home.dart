import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/widgets/left_drawer.dart';
import 'userprofile/user_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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