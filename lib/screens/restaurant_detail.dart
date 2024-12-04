import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/models/restaurant.dart';

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
            ),
            
            TextButton(
              onPressed: () {
                final newRating = double.tryParse(_dialogRatingController.text);
                if (newRating != null && newRating >= 1.0 && newRating <= 5.0) {
                  setState(() {
                    widget.restaurant.addRating(newRating);
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
        title: Text(widget.restaurant.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.restaurant.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.restaurant.description,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Kategori: ",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF28A745)),
                ),
                Text(
                  widget.restaurant.category,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rating: ",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF28A745)),
                ),
                Text(
                  widget.restaurant.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _showRatingDialog,
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
                  child: const Text('Berikan Rating'),
                ),
                const SizedBox(height: 16),
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.restaurant.foodItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        widget.restaurant.foodItems[index],
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
