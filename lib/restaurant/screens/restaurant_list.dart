import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/restaurant/models/restaurant.dart';
import 'package:golekmakanrek_mobile/restaurant/screens/restaurant_detail.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RestaurantList extends StatefulWidget {
  const RestaurantList({super.key});

  @override
  State<RestaurantList> createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> with SingleTickerProviderStateMixin {
  Map<String, bool> followStatus = {};
  Future<List<Restaurant>>? _restaurantFuture;
  
  @override
  void initState() {
    super.initState();
    _restaurantFuture = fetchRestaurant(context.read<CookieRequest>());
  }

  Future<List<Restaurant>> fetchRestaurant(CookieRequest request) async {
    final response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/get_restaurant/');

    var data = response;

    List<Restaurant> listResto = [];
    for (var d in data) {
      if (d != null) {
        listResto.add(Restaurant.fromJson(d));
      }
    }
    return listResto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Restaurant Preview",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _buildRestaurantList(), // Tampilkan daftar restoran
    );
  }

  Widget _buildRestaurantList() {
    return FutureBuilder(
      future: _restaurantFuture,
      builder: (context, AsyncSnapshot<List<Restaurant>> snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'No restaurants found!',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RestaurantList(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data![index].fields.nama,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(snapshot.data![index].fields.deskripsi.toString().trim()),
                        const SizedBox(height: 10),
                        Text(
                          snapshot.data![index].fields.kategori,
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 86, 96, 88),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Menambahkan tombol Follow dan Detail di bawah
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () => toggleFollow(snapshot.data![index].fields.nama),
                                style: TextButton.styleFrom(
                                  backgroundColor: followStatus[snapshot.data![index].fields.nama] == true
                                      ? const Color(0xFFFFC107) // Kuning jika diikuti
                                      : const Color(0xFF28A745), // Hijau jika belum
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  followStatus[snapshot.data![index].fields.nama] == true
                                      ? 'Following'
                                      : 'Follow',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),

                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  // Tambahkan aksi untuk Detail
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RestaurantDetailPage(
                                        restaurant: snapshot.data![index], // Ganti dengan halaman detail restoran
                                      ),
                                    ),
                                  );
                                },
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
                                child: const Text('Detail'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  void toggleFollow(String restaurantName) {
    setState(() {
      followStatus[restaurantName] = !(followStatus[restaurantName] ?? false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          followStatus[restaurantName]! 
              ? 'Anda mengikuti $restaurantName!' 
              : 'Anda berhenti mengikuti $restaurantName!',
        ),
      ),
    );
  }
}