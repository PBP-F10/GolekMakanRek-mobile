import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/userprofile/screens/user_profile_page.dart';
import 'package:golekmakanrek_mobile/wishlist/screens/wishlist.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orange.shade800,
              
            ),
            child: const Column(
              children: [
                Text(
                  'GolekMakanRek!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(2)),
              ],
            ),          
          ),

          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Wishlist'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WishlistPage(),
                  ));
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Profile'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(),
                  ));
            },
          ),
          
        ],
      ),
    );
  }
}