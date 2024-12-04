import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/wishlist/models/food.dart';
import 'package:golekmakanrek_mobile/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:golekmakanrek_mobile/wishlist/models/item.dart';


class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  Future<List<Wishlist>> fetchWishlist(CookieRequest request) async {
    final responsewishlist = await request.get('http://127.0.0.1:8000/json/');
    final responsefood = await request.get('http://127.0.0.1:8000/food-json/');
    var datawishlist = responsewishlist;
    var datafood = responsefood;
    
    List<Food> listFood = [];
    for (var d in datafood) {
      if (d != null) {
        listFood.add(Food.fromJson(d));
      }
    }

    List<Wishlist> listWishlist = [];
    for (var d in datawishlist) {
      for (var food in listFood) {
        var wishlist = Wishlist.fromJson(d);
        if (d != null && food.pk == wishlist.fields.item) {
          wishlist.fields.food = food;
          listWishlist.add(wishlist);
        }
      }
    }

    return listWishlist;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist List'),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () async {
          final response = await request.logout(
              "http://127.0.0.1:8000/auth/logout/");
          String message = response["message"];
          if (context.mounted) {
              if (response['status']) {
                  String uname = response["username"];
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("$message Sampai jumpa, $uname."),
                  ));
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
              } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(message),
                      ),
                  );
              }
          }
        }, 
        child: const Text(
            "Save",
            style: TextStyle(color: Colors.white),
          ),
      ),
      body: FutureBuilder(
        future: fetchWishlist(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'Belum ada item yang ditambahkan.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WishlistDetailPage(
                          wishlist: snapshot.data![index],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data![index].fields.food.fields.nama,
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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

class WishlistDetailPage extends StatelessWidget {
  final Wishlist wishlist;

  const WishlistDetailPage({super.key, required this.wishlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wishlist.fields.food.fields.nama),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wishlist.fields.food.fields.nama,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "Rp${wishlist.fields.food.fields.harga}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              "Description:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(wishlist.fields.food.fields.deskripsi),
          ],
        ),
      ),
    );
  }
}