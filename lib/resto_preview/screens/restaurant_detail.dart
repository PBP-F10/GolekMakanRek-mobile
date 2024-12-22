import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/resto_preview/models/restaurant.dart';
import 'package:golekmakanrek_mobile/food_review/models/food.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:golekmakanrek_mobile/food_review/widgets/pop_up_login.dart';
import 'package:intl/date_symbol_data_local.dart';

const String baseUrl = 'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  double _userRating = 0.0;
  double _averageRating = 0.0;
  int _totalRatings = 0;
  final TextEditingController _commentController = TextEditingController();
  int _currentRating = 0;
  Map<String, double> _foodRatings = {};
  Map<String, String> _userRatingIds = {};
  List<Welcome> _foods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _fetchRestaurantRating();
    _fetchUserRating();
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

  Future<void> _fetchRestaurantRating() async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurant/get-restaurant-rating/${widget.restaurant.pk}/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _averageRating = data['average_rating'];
        _totalRatings = data['total_ratings'];
      });
    }
  }

  Future<void> _fetchUserRating() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
        '$baseUrl/restaurant/get-user-rating/${widget.restaurant.pk}/'
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
        '$baseUrl/restaurant/${widget.restaurant.pk}/submit-rating/',
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
          const SnackBar(
            content: Text('Rating submitted successfully'),
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

  Future<List<Welcome>> fetchFoods(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/main/food_json/');
      final ratingsResponse = await request.get('$baseUrl/food_review/foodrating_json/');

      List<dynamic> data = response is List ? response : json.decode(response);
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
          .where((d) => d != null && Welcome.fromJson(d).fields.restoran == widget.restaurant.fields.nama)
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
        '$baseUrl/food_review/delete-rating/$ratingId/',
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
    final ratingsResponse = await request.get('$baseUrl/food_review/foodrating_json/');
    
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
        '$baseUrl/food_review/get-user-rating/$foodId/'
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

    if (!await LoginCheckHelper.checkLoginStatus(context)) {
      return;
    }
    
    try {
      final response = await request.get(
        '$baseUrl/food_review/get-user-rating/$foodId/'
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
                  ? '$baseUrl/food_review/edit-rating/$existingRatingId/'
                  : '$baseUrl/food_review/add-rating/$foodId/';

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
      '$baseUrl/food_review/wishlist/check/?food_ids[]=$foodId',
    );
    
    if (response['status'] == 'success') {
      return response['wishlisted_items'].contains(foodId);
    }
    return false;
  }

  Future<void> _toggleWishlist(String foodId) async {
    
    final request = context.read<CookieRequest>();
    
    if (!await LoginCheckHelper.checkLoginStatus(context)) {
      return;
    }

    try {
      final response = await request.post(
        '$baseUrl/food_review/wishlist/toggle/$foodId/',
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

  void _showCommentsSheet(BuildContext context, String foodId, String foodName) async {
    if (!await LoginCheckHelper.checkLoginStatus(context)) {
      return;
    }

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
                  '$baseUrl/food_review/food/$foodId/comments/'
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
                    DateTime commentTime;
                    try {
                      commentTime = DateTime.parse(comment['timestamp']);
                    } catch (e) {
                      print('Error parsing timestamp: $e');
                      commentTime = DateTime.now();
                    }
                    String formattedTime = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(commentTime);
                    
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
                                        formattedTime,
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
                          '$baseUrl/food_review/food/$foodId/comment/',
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

  void _showRestaurantRatingDialog() async {

    if (!await LoginCheckHelper.checkLoginStatus(context)) {
      return;
    }

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
                    const SnackBar(
                      content: Text('Rating harus antara 1 dan 5'),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.orange.shade50,
              child: Column(
                children: [
                  Text(
                    widget.restaurant.fields.nama,
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.restaurant.fields.deskripsi,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Category: ${widget.restaurant.fields.kategori}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            "Restaurant Rating",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text(
                                " ${_averageRating.toStringAsFixed(1)}",
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                          Text(
                            'from $_totalRatings reviews',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your Rating: ${_userRating > 0 ? _userRating.toStringAsFixed(1) : 'Not rated yet'}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showRestaurantRatingDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF28A745),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(_userRating > 0 ? 'Update Rating' : 'Rate Restaurant'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Menu Items",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _foods.isEmpty
                      ? const Center(
                          child: Text('No food items available'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _foods.length,
                          itemBuilder: (context, index) {
                            var food = _foods[index].fields;
                            var foodId = _foods[index].pk;
                            
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      food.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Category: ${food.kategori}'),
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'id_ID',
                                            symbol: 'Rp',
                                            decimalDigits: 0,
                                          ).format(food.harga)
                                        ),
                                      ],
                                    ),
                                    trailing: _buildWishlistButton(foodId),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(food.deskripsi),
                                        const SizedBox(height: 8),
                                        _buildRatingDisplay(foodId),
                                        const SizedBox(height: 8),
                                        _buildRatingButtons(foodId, food.nama),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}