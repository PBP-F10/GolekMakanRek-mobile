import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/models/resto_preview/restaurant.dart';
import 'package:golekmakanrek_mobile/screens/resto_preview/restaurant_detail.dart';
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
  List<String> _followedRestaurants = [];

  @override
  void initState() {
    super.initState();
    _restaurantFuture = fetchRestaurant(context.read<CookieRequest>());
    _fetchFollowedRestaurants();
  }

  Future<List<Restaurant>> fetchRestaurant(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/get_restaurant/');
    var data = response;

    List<Restaurant> listResto = [];
    for (var d in data) {
      if (d != null) {
        listResto.add(Restaurant.fromJson(d));
      }
    }
    return listResto;
  }

  Future<void> _fetchFollowedRestaurants() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://127.0.0.1:8000/restaurant/status/');
    final data = response;

    if (data['has_follow'] != null) {
      setState(() {
        _followedRestaurants = List<String>.from(data['followed_restaurant']);
      });
    }

    for (var restaurant in _followedRestaurants) {
      followStatus[restaurant] = true;
    }
  }

  void toggleFollow(String restaurant) async {
    final request = context.read<CookieRequest>();
    bool isFollowed = followStatus[restaurant] ?? false;

    setState(() {
      followStatus[restaurant] = !isFollowed;
      if (followStatus[restaurant]!) {
        _followedRestaurants.add(restaurant);
      } else {
        _followedRestaurants.remove(restaurant);
      }
    });

    if (isFollowed) {
      await request.post('http://127.0.0.1:8000/restaurant/unfollow/$restaurant/', {});
    } else {
      await request.post('http://127.0.0.1:8000/restaurant/follow/$restaurant/', {});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          followStatus[restaurant]! 
              ? 'You are now following $restaurant!'
              : 'You have unfollowed $restaurant!',
        ),
      ),
    );
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
      body: _buildRestaurantList(),
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
              itemBuilder: (_, index) {
                var restaurant = snapshot.data![index];
                bool isFollowed = followStatus[restaurant.pk] ?? false;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: InkWell(
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => RestaurantDetailPage(
                    //         restaurant: restaurant,
                    //       ),
                    //     ),
                    //   );
                    // },
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 10), // Space for image placeholder
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.fields.nama,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  restaurant.fields.kategori,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 105, 106, 105),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: TextButton(
                                    onPressed: () => toggleFollow(restaurant.pk),
                                    style: TextButton.styleFrom(
                                      backgroundColor: isFollowed
                                          ? const Color(0xFFFFC107) 
                                          : const Color(0xFF28A745),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      isFollowed ? 'Following' : 'Follow',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 120,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RestaurantDetailPage(
                                            restaurant: restaurant, 
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
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Text(
                                      'Detail',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}
