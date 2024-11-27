import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/models/restaurant.dart';
import 'package:golekmakanrek_mobile/screens/food_review/food_list.dart';
import 'package:golekmakanrek_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  Future<List<Restaurant>> fetchRestaurants(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/main/restaurant_json/');
    var data = response;
    List<Restaurant> listRestaurants = [];
    for (var d in data) {
      if (d != null) {
        listRestaurants.add(Restaurant.fromJson(d));
      }
    }
    return listRestaurants;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchRestaurants(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'No restaurants found.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ListTile(
                    title: Text(
                      snapshot.data![index].fields.nama,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      snapshot.data![index].fields.kategori,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    trailing: const Icon(Icons.restaurant_menu),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantFoodListPage(
                            restaurantName: snapshot.data![index].fields.nama,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}