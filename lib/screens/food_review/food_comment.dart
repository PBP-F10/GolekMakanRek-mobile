import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class FoodCommentsPage extends StatefulWidget {
  final String foodId;
  final String foodName;

  const FoodCommentsPage({
    Key? key, 
    required this.foodId, 
    required this.foodName
  }) : super(key: key);

  @override
  _FoodCommentsPageState createState() => _FoodCommentsPageState();
}

class _FoodCommentsPageState extends State<FoodCommentsPage> {
  List<dynamic> _comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/food_review/food/${widget.foodId}/comments/'
      );

      setState(() {
        _comments = response['comments'];
      });
    } catch (e) {
      print('Error fetching comments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load comments: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${widget.foodName}'),
        centerTitle: true,
      ),
      body: _comments.isEmpty
        ? const Center(
            child: Text(
              'No reviews yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return ListTile(
                title: Text(
                  comment['username'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment['comment']),
                    const SizedBox(height: 4),
                    Text(
                      comment['formatted_time'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}