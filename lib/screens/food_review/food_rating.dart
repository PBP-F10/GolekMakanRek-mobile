import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class FoodRatingPage extends StatefulWidget {
  final String foodId;
  final String foodName;

  const FoodRatingPage({
    Key? key, 
    required this.foodId, 
    required this.foodName
  }) : super(key: key);

  @override
  _FoodRatingPageState createState() => _FoodRatingPageState();
}

class _FoodRatingPageState extends State<FoodRatingPage> {
  int _currentRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _hasExistingRating = false;
  String? _existingRatingId;

  @override
  void initState() {
    super.initState();
    _fetchUserRating();
  }

  Future<void> _fetchUserRating() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/food_review/get-user-rating/${widget.foodId}/'
      );

      if (response['has_rating']) {
        setState(() {
          _currentRating = response['rating'];
          _hasExistingRating = true;
          _existingRatingId = response['rating_id'].toString();
        });
      }
    } catch (e) {
      print('Error fetching user rating: $e');
    }
  }

  Future<void> _submitRating() async {
    final request = context.read<CookieRequest>();
    try {
      final url = _hasExistingRating
        ? 'http://127.0.0.1:8000/food_review/edit-rating/$_existingRatingId/'
        : 'http://127.0.0.1:8000/food_review/add-rating/${widget.foodId}/';

      // Convert to string explicitly
      final scoreString = _currentRating.toString();

      final response = await request.post(
        url,
        {'score': scoreString}
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_hasExistingRating 
              ? 'Rating updated successfully' 
              : 'Rating added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to submit rating'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error submitting rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitComment() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/food_review/food/${widget.foodId}/comment/',
        jsonEncode({'comment': _commentController.text.trim()})
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _commentController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to submit comment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error submitting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate ${widget.foodName}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Rate ${widget.foodName}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Star Rating
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
            const SizedBox(height: 16),
            Text(
              'Your Rating: $_currentRating/5',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Comment Section
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a review (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, 
                  vertical: 12
                ),
              ),
              maxLines: 4,
              minLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _currentRating > 0 ? _submitRating : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _currentRating > 0 
                  ? Colors.blue 
                  : Colors.grey,
              ),
              child: Text(
                _hasExistingRating ? 'Update Rating' : 'Submit Rating',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _commentController.text.trim().isNotEmpty 
                ? _submitComment 
                : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _commentController.text.trim().isNotEmpty
                  ? Colors.green
                  : Colors.grey,
              ),
              child: const Text(
                'Submit Comment',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}