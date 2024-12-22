import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/food_review/models/food.dart';
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
  Map<String, String> _userRatingIds = {};
  List<Welcome> _foods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    
    final request = context.read<CookieRequest>();
    await _updateFoodRatings();
    _foods = await fetchFoods(request);
    for (var food in _foods) {
      await _checkUserRating(food.pk);
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Welcome>> fetchFoods(CookieRequest request) async {
    try {
      final response = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/main/food_json/');
      final ratingsResponse = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/foodrating_json/');

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

  Future<void> _deleteRating(String ratingId, String foodId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/delete-rating/$ratingId/',
        {}
      );

      if (response['status'] == 'success') {
        setState(() {
          _userRatingIds.remove(foodId);
        });
        await _updateFoodRatings();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating deleted successfully'),
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
  }

  Future<void> _updateFoodRatings() async {
    final request = context.read<CookieRequest>();
    final ratingsResponse = await request.get('https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/foodrating_json/');
    
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

    setState(() {
      _foodRatings.clear();
      foodRatings.forEach((foodId, scores) {
        if (scores.isNotEmpty) {
          double average = scores.reduce((a, b) => a + b) / scores.length;
          _foodRatings[foodId] = average;
        }
      });
    });
  }

  Future<void> _checkUserRating(String foodId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/get-user-rating/$foodId/'
      );

      if (response['has_rating']) {
        setState(() {
          _userRatingIds[foodId] = response['rating_id'].toString();
        });
      } else {
        setState(() {
          _userRatingIds.remove(foodId);
        });
      }
    } catch (e) {
      print('Error checking user rating: $e');
    }
  }

  Future<void> _showRatingDialog(BuildContext context, String foodId, String foodName) async {
    bool hasExistingRating = false;
    int initialRating = 0;
    String? existingRatingId;

    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/get-user-rating/$foodId/'
      );

      if (response['has_rating']) {
        hasExistingRating = true;
        initialRating = response['rating'];
        existingRatingId = response['rating_id'].toString();
        setState(() {
          _currentRating = initialRating;
          _userRatingIds[foodId] = existingRatingId!;
        });
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }

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
                // http://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/edit-rating/$existingRatingId/
                // http://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/add-rating/$foodId/
                  ? 'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/edit-rating/$existingRatingId/'
                  : 'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/add-rating/$foodId/';

                try {
                  final response = await request.post(
                    url,
                    {'score': _currentRating.toString()}
                  );

                  if (response['status'] == 'success') {
                    Navigator.pop(context);
                    await _updateFoodRatings();
                    await _checkUserRating(foodId);
                    
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

  Widget _buildRatingButtons(String foodId, String foodName) {
    bool hasRating = _userRatingIds.containsKey(foodId);
    
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          height: 36,
          child: OutlinedButton.icon(
            onPressed: () {
              _showRatingDialog(
                context,
                foodId,
                foodName,
              );
            },
            icon: const Icon(
              Icons.star_border,
              color: Colors.amber,
              size: 20,
            ),
            label: Text(
              hasRating ? 'Update' : 'Rate',
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.amber,
              side: const BorderSide(
                color: Colors.amber,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        if (hasRating)
          SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () => _deleteRating(_userRatingIds[foodId]!, foodId),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              label: const Text(
                'Delete',
                style: TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(
                  color: Colors.red,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        SizedBox(
          height: 36,
          child: ElevatedButton.icon(
            onPressed: () {
              _showCommentsSheet(
                context,
                foodId,
                foodName,
              );
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
              size: 20,
            ),
            label: const Text(
              'Reviews',
              style: TextStyle(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 115, 0, 255),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistButton(String foodId) {
    return FutureBuilder<bool>(
      future: _checkIfWishlisted(foodId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        
        bool isWishlisted = snapshot.data ?? false;
        
        return IconButton(
          icon: Icon(
            isWishlisted ? Icons.bookmark : Icons.bookmark_border,
            color: isWishlisted ? const Color.fromARGB(255, 0, 71, 2) : null,
          ),
          onPressed: () => _toggleWishlist(foodId),
        );
      },
    );
  }

  Future<bool> _checkIfWishlisted(String foodId) async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/wishlist/check/?food_ids[]=$foodId',
    );
    
    if (response['status'] == 'success') {
      return response['wishlisted_items'].contains(foodId);
    }
    return false;
  }

  Future<void> _toggleWishlist(String foodId) async {
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.post(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/wishlist/toggle/$foodId/',
        {},
      );
      
      if (response['status'] == 'success') {
        setState(() {}); // refresh (todo: search a better way)
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update wishlist"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                  'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/food/$foodId/comments/'
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
                          'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/food_review/food/$foodId/comment/',
                          {
                            'comment': _commentController.text.trim()
                          },
                        );

                        if (response['status'] == 'success') {
                          _commentController.clear();
                          FocusScope.of(context).unfocus();
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
                    color: Colors.deepOrange[300],
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Makanan - ${widget.restaurantName}',
        ),
        centerTitle: true,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 173, 51),
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
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _foods.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _foods.length,
                    itemBuilder: (context, index) {
                      var food = _foods[index].fields;
                      var foodId = _foods[index].pk;
                      
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
                                color: Colors.orange[100],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildWishlistButton(foodId),
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
                                          symbol: 'Rp',
                                          decimalDigits: 0,
                                        ).format(food.harga),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
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
                                  const SizedBox(height: 8),
                                  _buildRatingDisplay(foodId),
                                  const SizedBox(height: 16),
                                  _buildRatingButtons(foodId, food.nama),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}