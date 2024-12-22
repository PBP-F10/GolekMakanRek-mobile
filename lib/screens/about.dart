import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/widgets/left_drawer.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool isIndonesian = true;

  final Map<String, Map<String, String>> _content = {
    'en': {
      'appName': 'GolekMakanRek!',
      'tagline': 'Explore the Best Culinary in Surabaya',
      'ourStory': 'Our Story',
      'storyContent': 'Surabaya, as one of the major cities in Indonesia, has a diverse culinary wealth, ranging from street food to luxurious restaurants. However, with so many choices, both locals and tourists often find it difficult to determine a place to eat that suits their tastes and needs. This is where GolekMakanRek! came from—a platform designed to help Surabaya people and tourists explore and discover the best culinary in this city easily. GolekMakanRek! aims to be a solution for everyone who wants to enjoy delicious dishes without the hassle of choosing in the midst of the busy city.',
      'mainFeatures': 'Main Features',
      'easySearch': 'Easy Search',
      'searchDesc': 'Filter by food type, restaurant, or price',
      'ratingReviews': 'Ratings & Reviews',
      'ratingDesc': 'Read other users\' experiences and share yours',
      'wishlist': 'Wishlist',
      'wishlistDesc': 'Save favorite food to eat later',
      'statistics': 'GolekMakanRek! in Numbers',
      'menu': 'Menus',
      'accurate': 'Accurate',
      'users': 'Users',
    },
    'id': {
      'appName': 'GolekMakanRek!',
      'tagline': 'Jelajahi Kuliner Terbaik Surabaya',
      'ourStory': 'Cerita Kami',
      'storyContent': 'Surabaya, sebagai salah satu kota besar di Indonesia, memiliki kekayaan kuliner yang sangat beragam, mulai dari jajanan kaki lima hingga restoran mewah. Namun, dengan begitu banyak pilihan, baik penduduk lokal maupun wisatawan sering kali kebingungan menentukan tempat makan yang sesuai dengan selera dan kebutuhan mereka. Dari sinilah ide GolekMakanRek! muncul—sebuah platform yang dirancang untuk membantu masyarakat Surabaya dan para wisatawan menjelajahi serta menemukan kuliner terbaik di kota ini dengan mudah. GolekMakanRek! bertujuan menjadi solusi bagi setiap orang yang ingin menikmati hidangan lezat, tanpa harus repot memilih di tengah keramaian kota.',
      'mainFeatures': 'Fitur Utama',
      'easySearch': 'Pencarian Mudah',
      'searchDesc': 'Filter berdasarkan jenis makanan, restoran, atau harga',
      'ratingReviews': 'Rating & Ulasan',
      'ratingDesc': 'Baca pengalaman pengguna lain dan bagikan pengalaman Anda',
      'wishlist': 'Wishlist',
      'wishlistDesc': 'Simpan makanan favorit untuk dicicipi nanti',
      'statistics': 'GolekMakanRek! dalam Angka',
      'menu': 'Menu',
      'accurate': 'Akurat',
      'users': 'Pengguna',
    },
  };

  String getText(String key) {
    return _content[isIndonesian ? 'id' : 'en']![key] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About GolekMakanRek!',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.orange[800]),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    getText('appName'),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      getText('tagline'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.orange[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: Colors.orange[800],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        getText('ourStory'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    getText('storyContent'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getText('mainFeatures'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.search,
                    title: getText('easySearch'),
                    description: getText('searchDesc'),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.star,
                    title: getText('ratingReviews'),
                    description: getText('ratingDesc'),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.bookmark,
                    title: getText('wishlist'),
                    description: getText('wishlistDesc'),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.orange[800],
                borderRadius: BorderRadius.circular(32),
                image: const DecorationImage(
                  image: AssetImage('assets/images/pattern.png'),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    getText('statistics'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatistic(
                        context: context,
                        number: '300+',
                        label: getText('menu'),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.white24,
                      ),
                      _buildStatistic(
                        context: context,
                        number: '99%',
                        label: getText('accurate'),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.white24,
                      ),
                      _buildStatistic(
                        context: context,
                        number: '50K+',
                        label: getText('users'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              setState(() {
                isIndonesian = !isIndonesian;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    isIndonesian ? 'assets/images/id.png' : 'assets/images/en.png',
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isIndonesian ? 'ID' : 'EN',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.orange[800],
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic({
    required BuildContext context,
    required String number,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}