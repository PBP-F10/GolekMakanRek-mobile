import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../userprofile/screens/user_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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