import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:golekmakanrek_mobile/screens/homepage/item_list.dart';
import 'package:golekmakanrek_mobile/screens/authentication/login.dart';
import 'package:golekmakanrek_mobile/screens/userprofile/user_profile_page.dart';
import 'package:golekmakanrek_mobile/screens/food_review/restaurant_list.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              children: [
                Text(
                  'GolekMakanRek',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ItemList()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Add your about page navigation here
            },
          ),
          if (!request.loggedIn) ...[
            const Divider(
              color: Color(0xFF2C5F2D),
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.fastfood_outlined),
              title: const Text('Restaurant List'),
              onTap: () {
                Navigator.push(
                  context,
                  // todo: integrate with resto preview
                  MaterialPageRoute(builder: (context) => const RestaurantListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.forum_outlined),
              title: const Text('Forum'),
              onTap: () {
                // todo: forum app
              },
            ),
            const Divider(
              color: Color(0xFF2C5F2D),
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            ListTile(
              leading: const Icon(Icons.person_outlined),
              title: const Text('User Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Wishlist'),
              onTap: () {
                // todo: wishlist
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final response = await request.logout(
                    "http://127.0.0.1:8000/logout-external/");
                if (response['status']) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Successfully logged out!"),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ItemList()),
                    );
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}