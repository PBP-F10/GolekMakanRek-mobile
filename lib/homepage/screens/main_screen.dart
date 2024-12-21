import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/homepage/screens/item_list.dart';
import 'package:golekmakanrek_mobile/resto_preview/screens/restaurant_list.dart';
import 'package:golekmakanrek_mobile/screens/about.dart';
import 'package:golekmakanrek_mobile/authentication/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  List<Widget> _getWidgetOptions() {
    final request = context.watch<CookieRequest>();
    final List<Widget> baseWidgets = [
      const ItemList(),
      const AboutPage(),
      const RestaurantList(),
    ];

    if (request.loggedIn) {
      baseWidgets.add(const ItemList()); // navigate to forum page
    }
    
    return baseWidgets;
  }

  List<BottomNavigationBarItem> _getNavigationItems() {
    final request = context.watch<CookieRequest>();
    final List<BottomNavigationBarItem> baseItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.info),
        label: 'About',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu),
        label: 'Restaurant',
      ),
    ];

    // kl user belum login: gada tombol forum
    if (request.loggedIn) {
      baseItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.forum),
        label: 'Forum',
      ));
    }
    
    return baseItems;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _getNavigationItems();
    if (_selectedIndex >= items.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: _getWidgetOptions()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}