import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/restaurant/models/restaurant.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  RestaurantDetailPage({super.key, required this.restaurant});

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  double? _userRating; // Variabel untuk menyimpan penilaian pengguna

  // Fungsi untuk menampilkan pop-up untuk menambah rating
  void _showRatingDialog() {
    final TextEditingController _dialogRatingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Berikan Rating"),
          content: TextField(
            controller: _dialogRatingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Masukkan rating (1-5)",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
            ),
            TextButton(
              onPressed: () {
                final newRating = double.tryParse(_dialogRatingController.text);
                if (newRating != null && newRating >= 1.0 && newRating <= 5.0) {
                  setState(() {
                    _userRating = newRating;
                  });
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rating berhasil ditambahkan!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan rating yang valid (1-5)!')),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF28A745), // Warna latar tombol
                foregroundColor: Colors.white, // Warna teks
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Restoran"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Menampilkan Nama Restoran
                Text(
                  widget.restaurant.fields.nama,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Menampilkan Deskripsi Restoran
                Text(
                  widget.restaurant.fields.deskripsi,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Menampilkan Kategori Restoran
                const Text(
                  "Kategori: ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28A745),
                  ),
                ),
                Text(
                  widget.restaurant.fields.kategori,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                // Tombol untuk memberikan rating
                TextButton(
                  onPressed: _showRatingDialog,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF28A745),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Berikan Rating'),
                ),
                const SizedBox(height: 16),
                // Menampilkan rating yang sudah diberikan
                if (_userRating != null) ...[
                  const Text(
                    "Penilaianmu: ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF28A745),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userRating!.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Makanan:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF28A745)),
                ),
                const SizedBox(height: 8),
                // Menambahkan informasi makanan atau menu lainnya
                Text(
                  'Menu makanan belum ditambahkan.',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
