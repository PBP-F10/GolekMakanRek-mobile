import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _restaurantResults = [];
  String? _selectedRestaurant;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Debounced search function
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _restaurantResults = [];
      });
      return;
    }

    try {
      final request = context.read<CookieRequest>();

      // Manually construct the URL with query parameters
      final url =
          'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/search_restaurants/?q=$query';

      final response = await request.get(url);

      setState(() {
        _restaurantResults = List<Map<String, dynamic>>.from(response['restaurants']);
      });
    } catch (e) {
      setState(() {
        _restaurantResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching restaurants: $e')),
      );
    }
  }

  Future<void> _submitPost() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = context.read<CookieRequest>();

      // Prepare the data for the request
      final data = {
        'text': _textController.text,
      };
      if (_selectedRestaurant != null) {
        data['restaurant_id'] = _selectedRestaurant!;
      }

      final response = await request.post(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/create_post_flutter/',
        data,
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        Navigator.pop(context, true); // Pass true to indicate a new post
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Error creating post.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  Widget _buildRestaurantSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search Restaurants',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        if (_restaurantResults.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            itemCount: _restaurantResults.length,
            itemBuilder: (context, index) {
              final restaurant = _restaurantResults[index];
              return ListTile(
                title: Text(restaurant['nama']),
                onTap: () {
                  setState(() {
                    _selectedRestaurant = restaurant['id'].toString();
                    _searchController.text = restaurant['nama'];
                    _restaurantResults = [];
                  });
                },
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Post"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      "Post Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Post Text Field
                    TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: "Post Text",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter text for the post.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Restaurant Search Field
                    const Text(
                      "Select a Restaurant",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildRestaurantSearch(),
                    const SizedBox(height: 24),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: _submitPost,
                        child: const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}