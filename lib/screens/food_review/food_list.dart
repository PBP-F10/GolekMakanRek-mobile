import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/models/food_review/food.dart';
import 'package:golekmakanrek_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

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
  final TextEditingController _commentController = TextEditingController();
  int _currentRating = 0;
  Map<String, double> _foodRatings = {};

  Future<List<Welcome>> fetchFoods(CookieRequest request) async {
    try {
      final response = await request.get('http://127.0.0.1:8000/main/food_json/');
      final ratingsResponse = await request.get('http://127.0.0.1:8000/food_review/foodrating_json/');

      List<dynamic> data;
      if (response is List) {
        data = response;
      } else {
        data = json.decode(response);
      }

      List<dynamic> ratingsData = ratingsResponse is List ? ratingsResponse : json.decode(ratingsResponse);
      Map<String, List<int>> foodRatings = {};
      
      for (var rating in ratingsData) {
        String foodId = rating['fields']['deskripsi_food'];
        int score = rating['fields']['score'];
        if (!foodRatings.containsKey(foodId)) {
          foodRatings[foodId] = [];
        }
        foodRatings[foodId]!.add(score);
      }

      foodRatings.forEach((foodId, scores) {
        if (scores.isNotEmpty) {
          double average = scores.reduce((a, b) => a + b) / scores.length;
          _foodRatings[foodId] = average;
        }
      });

      return data
          .where((d) => d != null && Welcome.fromJson(d).fields.restoran == widget.restaurantName)
          .map((d) => Welcome.fromJson(d))
          .toList();
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<void> _showRatingDialog(BuildContext context, String foodId, String foodName) async {
    bool hasExistingRating = false;
    int initialRating = 0;
    String? existingRatingId;

    final request = context.read<CookieRequest>();
    
    // Fetch existing rating
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/food_review/get-user-rating/$foodId/'
      );

      if (response['has_rating']) {
        hasExistingRating = true;
        initialRating = response['rating'];
        existingRatingId = response['rating_id'].toString();
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }

    // Show rating dialog
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate $foodName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _currentRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              Text(
                'Your Rating: $_currentRating/5',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _currentRating > 0 ? () async {
                final url = hasExistingRating
                  ? 'http://127.0.0.1:8000/food_review/edit-rating/$existingRatingId/'
                  : 'http://127.0.0.1:8000/food_review/add-rating/$foodId/';

                try {
                  final response = await request.post(
                    url,
                    {'score': _currentRating.toString()}
                  );

                  if (response['status'] == 'success') {
                    setState(() {
                      _foodRatings[foodId] = response['food_rating'].toDouble();
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(hasExistingRating 
                          ? 'Rating updated successfully' 
                          : 'Rating added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } : null,
              child: Text(hasExistingRating ? 'Update' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDisplay(String foodId) {
  return Row(
    children: [
      const Icon(Icons.star, color: Colors.amber, size: 16),
      const SizedBox(width: 4),
      Text(
        _foodRatings[foodId]?.toStringAsFixed(1) ?? 'No ratings',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    ],
  );
}

  void _showCommentsSheet(BuildContext context, String foodId, String foodName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.grey[300],
                    ),
                  ),
                  Text(
                    'Reviews for $foodName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: context.read<CookieRequest>().get(
                  'http://127.0.0.1:8000/food_review/food/$foodId/comments/'
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final comments = (snapshot.data?['comments'] as List?) ?? [];

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    child: Text(
                                      comment['username'][0].toUpperCase(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['username'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          comment['formatted_time'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(comment['comment']),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a review...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () async {
                      if (_commentController.text.trim().isEmpty) return;

                      try {
                        final response = await context.read<CookieRequest>().post(
                          'http://127.0.0.1:8000/food_review/food/$foodId/comment/',
                          {
                            'comment': _commentController.text.trim()
                          },  // Changed from jsonEncode to direct map
                        );

                        if (response['status'] == 'success') {
                          _commentController.clear();
                          // Close keyboard
                          FocusScope.of(context).unfocus();
                          // Refresh comments by rebuilding the widget
                          Navigator.pop(context);
                          _showCommentsSheet(context, foodId, foodName);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send),
                    color: Colors.deepOrange[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.restaurantName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Menu List',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
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
                          'No food items available at ${widget.restaurantName}',
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
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var food = snapshot.data![index].fields;
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food.nama,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Category: ${food.kategori}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp ',
                                        decimalDigits: 0,
                                      ).format(food.harga),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    if (food.diskon > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${food.diskon}% OFF',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.deskripsi,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                                _buildRatingDisplay(snapshot.data![index].pk),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        _showRatingDialog(
                                          context,
                                          snapshot.data![index].pk,
                                          food.nama,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.star_border,
                                        color: Colors.amber,
                                      ),
                                      label: const Text('Rate'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.amber,
                                        side: const BorderSide(
                                          color: Colors.amber,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _showCommentsSheet(
                                          context,
                                          snapshot.data![index].pk,
                                          food.nama,
                                        );
                                      },
                                      icon: const Icon(Icons.chat_bubble_outline),
                                      label: const Text('Reviews'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}