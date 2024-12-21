// lib/widgets/login_check_dialog.dart

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:golekmakanrek_mobile/authentication/screens/login.dart';

class LoginCheckHelper {
  static Future<bool> checkLoginStatus(BuildContext context) async {
    final request = context.read<CookieRequest>();
    bool isLoggedIn = request.loggedIn;

    if (!isLoggedIn) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Login Required',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Please login to access this feature.',
              style: TextStyle(fontSize: 16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Login'),
              ),
            ],
          );
        },
      );
      return false;
    }
    return true;
  }
}