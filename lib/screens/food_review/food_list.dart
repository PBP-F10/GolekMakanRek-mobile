import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/models/food_review/food.dart';
import 'package:golekmakanrek_mobile/widgets/left_drawer.dart';
import 'package:golekmakanrek_mobile/screens/food_review/food_rating.dart';
import 'package:golekmakanrek_mobile/screens/food_review/food_comment.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class RestaurantFoodListPage extends StatefulWidget {
  final String restaurantName;
  
  const RestaurantFoodListPage({
    super.key, 
    required this.restaurantName
  });

  @override
  State<RestaurantFoodListPage> createState() => _RestaurantFoodListPageState();
}

class _RestaurantFoodListPageState extends State<RestaurantFoodListPage> {
  Future<List<Welcome>> fetchFoods(CookieRequest request) async {
    try {
      final response = await request.get('http://127.0.0.1:8000/main/food_json/');

      List<dynamic> data;
      if (response is List) {
        data = response;
      } else {
        data = json.decode(response);
      }

      List<Welcome> listFoods = [];
      for (var d in data) {
        if (d != null) {
          Welcome food = Welcome.fromJson(d);
          if (food.fields.restoran == widget.restaurantName) {
            listFoods.add(food);
          }
        }
      }
      return listFoods;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Makanan - ${widget.restaurantName}'),
        centerTitle: true,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Makanan di ${widget.restaurantName}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchFoods(request),
              builder: (context, AsyncSnapshot<List<Welcome>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } 
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 100,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tidak ada makanan di ${widget.restaurantName}',
                          style: const TextStyle(
                            fontSize: 20, 
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var food = snapshot.data![index].fields;
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          food.nama,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Kategori: ${food.kategori}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Harga: Rp ${food.harga}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (food.diskon > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Diskon: ${food.diskon}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Deskripsi: ${food.deskripsi}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.star_border, color: Colors.amber),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodRatingPage(
                                      foodId: snapshot.data![index].pk,
                                      foodName: food.nama,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.comment, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodCommentsPage(
                                      foodId: snapshot.data![index].pk,
                                      foodName: food.nama,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}