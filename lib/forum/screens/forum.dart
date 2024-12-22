import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/forum/models/post.dart';
import 'package:golekmakanrek_mobile/forum/models/comment.dart';
import 'package:golekmakanrek_mobile/forum/screens/post_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Post> _posts = [];
  Map<int, String> _users = {}; // Map: userId -> username
  Map<int, String> _commentUsers = {}; // Additional map if your comments need user info
  Map<int, List<Comment>> postComments = {};
  Map<String, String> _restaurants = {}; 
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isFetching = false;

  // For debugging raw JSON response
  String _rawPostResponse = '';

  // Assume you have a way to get the current user ID (or username).
  // In many apps, you'd fetch this after login or from your request instance.
  // For example, if CookieRequest stores the ID in request.jsonData, you might do:
  // final int currentUserId = context.watch<CookieRequest>().jsonData['user_id'];
  // Here, we’ll just hardcode a sample ID:
  int currentUserId = 1; // Example: user with ID=1 is logged in

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      fetchData(request);
    });
  }

  // --------------------------------------------------------
  // FETCH DATA (USERS, POSTS, COMMENTS)
  // --------------------------------------------------------
  Future<void> fetchData(CookieRequest request) async {
    if (_isFetching) return; // Prevent simultaneous calls
    _isFetching = true;
    try {
      // -------------------------------------------
      // 1. Fetch posts
      // -------------------------------------------
      final postResponse = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/post_json/',
      );

      // Save raw JSON for debugging
      setState(() {
        _rawPostResponse = jsonEncode(postResponse);
      });

      // postResponse is already a list of post objects
      List<dynamic> postData = postResponse;

      // -------------------------------------------
      // 2. Fetch comments
      // -------------------------------------------
      final commentResponse = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/comment_json/',
      );
      List<dynamic> commentData = commentResponse;

      // -------------------------------------------
      // 3. Fetch user list (get_all_users)
      // -------------------------------------------
      final userResponse = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/get_all_users/',
      );
      List<dynamic> userData = userResponse['users'];

      final restaurantResponse = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/restaurant_json/',
      );
      List<dynamic> restaurantData = restaurantResponse;

      // -------------------------------------------
      // Populate _users map (userId -> username)
      // -------------------------------------------
      Map<int, String> fetchedUsers = {};
      for (var user in userData) {
        int userId = user['id'];
        String username = user['username'];
        fetchedUsers[userId] = username;
      }

      // -------------------------------------------
      // Convert postData to Post objects
      // -------------------------------------------
      List<Post> fetchedPosts =
          postData.map((item) => Post.fromJson(item)).toList();

      // -------------------------------------------
      // Create comments map: postId -> list of Comments
      // -------------------------------------------
      Map<int, List<Comment>> commentsMap = {};
      for (var item in commentData) {
        Comment comment = Comment.fromJson(item);
        if (comment.fields.post != null) {
          commentsMap.putIfAbsent(comment.fields.post!, () => []).add(comment);
        }
      }


      Map<String, String> fetchedRestaurants = {};
    for (var item in restaurantData) {
      String restaurantId = item['pk'];
      String restaurantName = item['fields']['nama'];
      fetchedRestaurants[restaurantId] = restaurantName;
    }

      // -------------------------------------------
      // Update the state
      // -------------------------------------------
      setState(() {
        _users = fetchedUsers;
        _posts = fetchedPosts;
        postComments = commentsMap;
        _isLoading = false;
        _restaurants = fetchedRestaurants;

      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    } finally {
      _isFetching = false;
    }
  }

  // --------------------------------------------------------
  // REFRESH
  // --------------------------------------------------------
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final request = context.read<CookieRequest>();
    await fetchData(request);
  }

  // --------------------------------------------------------
  // GET USERNAME BY USER ID
  // --------------------------------------------------------
  String getUsername(int userId) {
    return _users[userId] ?? 'Unknown User';
  }

  // --------------------------------------------------------
  // BUILD
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jelajahi Makanan di Surabaya!"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildPostListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
          // Refresh posts if a new post was created
          if (result == true) {
            _refreshData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // --------------------------------------------------------
  // ERROR VIEW
  // --------------------------------------------------------
  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Terjadi Kesalahan:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Display error message
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                _errorMessage,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshData(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Coba Lagi"),
          ),

          // Debug: Show raw post response if needed
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(
                _rawPostResponse.isNotEmpty
                    ? _rawPostResponse
                    : "No data available.",
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // POSTS LIST VIEW
  // --------------------------------------------------------
  Widget _buildPostListView() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final comments = postComments[post.pk] ?? [];
          final username = getUsername(post.fields.user);
          return PostCard(
            post: post,
            comments: comments,
            username: username, // Pass username directly
            onPostUpdated: _refreshData,
            currentUserId: currentUserId, // Pass ID of logged-in user
            restaurantName: _restaurants[post.fields.restaurant] ?? 'Unknown Restaurant',

          );
        },
      ),
    );
  }
}
void sharePost(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("URL telah disalin!")),
  );
}
// ---------------------------------------------------------------------------
// PostCard: menampilkan detail Post + Aksi
// ---------------------------------------------------------------------------
class PostCard extends StatefulWidget {
  final Post post;
  final List<Comment> comments;
  final String username;  // Display name of the post owner
  final VoidCallback onPostUpdated;
  final int currentUserId;  // ID of the currently logged-in user
  final String restaurantName;

  const PostCard({
    Key? key,
    required this.post,
    required this.comments,
    required this.username,
    required this.onPostUpdated,
    required this.currentUserId,
    required this.restaurantName, // New parameter

  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool showComments = false;
  bool isLiked = false;
  int likeCount = 0; // We will hide the number of likes display per your request

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.fields.likeCount;
  }

  // --------------------------------------------------------
  // LIKE
  // --------------------------------------------------------
  Future<void> toggleLike() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/like_post_flutter/',
        {
          'post_id': widget.post.pk.toString(),
        },
      );
      if (response['status'] == 'success') {
        setState(() {
          isLiked = response['liked'];
          likeCount = response['like_count'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal like: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error like: $e")),
      );
    }
  }

  // --------------------------------------------------------
  // DELETE POST
  // --------------------------------------------------------
  Future<void> deletePost() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/delete_post_flutter/',
        {
          'post_id': widget.post.pk.toString(),
        },
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post berhasil dihapus!")),
        );
        widget.onPostUpdated(); // Refresh posts
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus post: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error menghapus post: $e")),
      );
    }
  }

  // --------------------------------------------------------
  // COMMENT
  // --------------------------------------------------------
  Future<void> postComment(String commentText) async {
  try {
    final request = context.read<CookieRequest>();
    final response = await request.post(
      'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/comment_post_flutter/',
      {
        'post_id': widget.post.pk.toString(),
        'comment': commentText,
      },
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Komentar berhasil ditambahkan!")),
      );

      // Add the new comment to the comments list
      final newComment = Comment.fromJson(response['comment']);
      setState(() {
        widget.comments.add(newComment);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal komentar: ${response['message']}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error komentar: $e")),
    );
  }
}

  // --------------------------------------------------------
  // BUILD
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final comments = widget.comments;

    bool canDeletePost = (post.fields.user == widget.currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------
            // Header
            // --------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display post owner's username
                Text(
                  "Username: ${widget.username}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatDate(post.fields.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 8),
            // Restaurant
            if (post.fields.restaurant != null &&
                post.fields.restaurant!.isNotEmpty)
              Text(
                "Restoran: ${post.fields.restaurant}",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                  fontSize: 14,
                ),
              ),

            const SizedBox(height: 8),
            // Post Content
            Text(
              post.fields.text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            if (post.fields.image != null && post.fields.image!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(post.fields.image!),
              ),

            const SizedBox(height: 16),

            // --------------------------
            // Action Buttons
            // (No like count displayed per your request)
            // --------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like button, but no like count text
                IconButton(
                  onPressed: toggleLike,
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    color: isLiked ? Colors.blue : Colors.grey,
                  ),
                ),

                // Comment button
                IconButton(
                  onPressed: () => setState(() {
                    showComments = !showComments;
                  }),
                  icon: const Icon(Icons.comment_outlined),
                ),

                // Share button
                IconButton(
                  onPressed: () => sharePost(context),
                  icon: const Icon(Icons.share_outlined),
                ),

                // Conditional delete button if user owns the post
                if (canDeletePost)
                  IconButton(
                    onPressed: () => deletePost(),
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                  ),
              ],
            ),

            // --------------------------
            // Comments Section
            // --------------------------
            if (showComments) _buildCommentsSection(comments),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // COMMENTS SECTION
  // --------------------------------------------------------
  Widget _buildCommentsSection(List<Comment> comments) {
    return Column(
      children: [
        ...comments.map((c) => _buildComment(c)).toList(),
        const SizedBox(height: 8),
        _buildCommentInput(),
      ],
    );
  }

  // --------------------------------------------------------
  // BUILD COMMENT
  // (Display username in each comment)
  // --------------------------------------------------------
  Widget _buildComment(Comment comment) {
    // Check if the current user can edit this comment
    bool canEditComment = (comment.fields.user == widget.currentUserId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display commenter's username
          Text(
            "Comment by UserID ${comment.fields.user}", // or fetch a map for comment user
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(comment.fields.text),
          ),
          // If the user is the commenter, show an "edit" button
          if (canEditComment)
            TextButton(
              onPressed: () => _editCommentDialog(comment),
              child: const Text("Edit Comment"),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // EDIT COMMENT DIALOG
  // --------------------------------------------------------
  void _editCommentDialog(Comment comment) {
    final TextEditingController editController =
        TextEditingController(text: comment.fields.text);

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Edit Komentar"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: "Masukkan komentar baru...",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _editComment(comment, editController.text.trim());
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------
  // EDIT COMMENT LOGIC (async, no reload)
  // --------------------------------------------------------
  Future<void> _editComment(Comment comment, String newContent) async {
    if (newContent.isEmpty) return;
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/edit_comment_flutter/',
        {
          'comment_id': comment.pk.toString(),
          'text': newContent,
        },
      );

      if (response['status'] == 'success') {
        setState(() {
          // Update comment text locally
          comment.fields.text = newContent;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Komentar berhasil diedit!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal edit komentar: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error edit komentar: $e")),
      );
    }
  }

  // --------------------------------------------------------
  // BUILD COMMENT INPUT (async, no reload)
  // --------------------------------------------------------
  Widget _buildCommentInput() {
    final TextEditingController commentController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: "Tambah komentar...",
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final text = commentController.text.trim();
            if (text.isNotEmpty) {
              postComment(text);
              commentController.clear();
            }
          },
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }

  // --------------------------------------------------------
  // FORMAT DATE
  // --------------------------------------------------------
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}