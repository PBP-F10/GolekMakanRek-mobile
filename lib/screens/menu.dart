import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/widgets/left_drawer.dart';

class MyHomePage extends StatelessWidget {
    MyHomePage({super.key});
    
    @override
    Widget build(BuildContext context) {
      // Scaffold menyediakan struktur dasar halaman dengan AppBar dan body.
      return Scaffold(
        // AppBar adalah bagian atas halaman yang menampilkan judul.
        appBar: AppBar(
          // Judul aplikasi "Mental Health Tracker" dengan teks putih dan tebal.
          title: const Text(
            'GolekMakanRek!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          // Warna latar belakang AppBar diambil dari skema warna tema aplikasi.
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        // Body halaman dengan padding di sekelilingnya.
        drawer: const LeftDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          // Menyusun widget secara vertikal dalam sebuah kolom.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
      );
    }
}