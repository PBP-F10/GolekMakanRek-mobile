import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/models/resto_preview/restaurant.dart';
import 'package:golekmakanrek_mobile/models/resto_preview/food.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  double _userRating = 0.0;
  double _averageRating = 0.0;
  late Future<List<Food>> _foodList;
  int _totalRatings = 0;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantRating();
    _fetchUserRating();
    _foodList = fetchFoods();
  }

  Future<void> _fetchRestaurantRating() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/restaurant/get-restaurant-rating/${widget.restaurant.pk}/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _averageRating = data['average_rating'];
        _totalRatings = data['total_ratings'];
      });
    } else {
      throw Exception('Failed to load restaurant rating');
    }
  }

  Future<void> _fetchUserRating() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
        'http://127.0.0.1:8000/restaurant/get-user-rating/${widget.restaurant.pk}/'
      );
      
      final data = response;
      
      if (data['has_rating'] != null) {
        setState(() {
          _userRating = data['user_rating'];
        });
      } 
  }

  void _submitRating(double rating) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/restaurant/${widget.restaurant.pk}/submit-rating/',
        {
          'score': rating.toString(),
        }
      );

      if (response['error'] == null) {
        setState(() {
          _averageRating = response['average_rating'];
          _userRating = rating;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rating submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to submit rating'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Food>> fetchFoods() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/main/food_json/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Food> listFoods = [];
      for (var d in data) {
        Food food = Food.fromJson(d);
        if (food.fields.restoran == widget.restaurant.fields.nama) {
          listFoods.add(food);
        }
      }
      return listFoods;
    } else {
      throw Exception('Failed to load foods');
    }
  }

  void _showRatingDialog() {
    final TextEditingController dialogRatingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rate This Restaurant"),
          content: TextField(
            controller: dialogRatingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter rating (1-5)",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7), 
                ),
                foregroundColor: Colors.orange.shade800,
                    
              )
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF28A745),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7), 
                )
              ),
              child: const Text('Submit'),
              onPressed: () {
                final rating = double.tryParse(dialogRatingController.text);
                if (rating != null && rating >= 1 && rating <= 5) {
                  _submitRating(rating);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Rating harus antara 1 dan 5'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
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
        title: const Text("Detail Restoran"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.restaurant.fields.nama,
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.restaurant.fields.deskripsi,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Kategori",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF28A745)),
                ),
                Text(
                  widget.restaurant.fields.kategori,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Penilaian",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF28A745)),
                ),
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  'dari $_totalRatings pengguna',
                  style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 105, 106, 105),),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Penilaianmu",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _userRating > 0 ? _userRating.toStringAsFixed(1) : "Belum ada rating",
                  style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 8, 2, 2)),
                ),
                const SizedBox(height: 13),
                TextButton(
                  onPressed: _showRatingDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28A745),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, 
                      vertical: 11,  
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7), 
                    ),
                  ),
                  child: const Text(
                    'Berikan Rating',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Makanan:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                FutureBuilder<List<Food>>(
                  future: _foodList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Text("Gagal memuat menu makanan");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("Tidak ada makanan di restoran ini");
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var food = snapshot.data![index].fields;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                food.nama,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
