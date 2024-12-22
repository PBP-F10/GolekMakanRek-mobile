import 'package:flutter/material.dart';
import 'package:golekmakanrek_mobile/forum/models/post.dart';
import 'package:golekmakanrek_mobile/forum/models/comment.dart';
import 'package:golekmakanrek_mobile/forum/screens/post_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:golekmakanrek_mobile/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Function to fetch the current username
Future<String> fetchUsername(CookieRequest request) async {
  try {
    // Fetch username from the API
    final response = await request.get(
      'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/auth/get_username/',
    );

    // Extract and return the username
    if (response['username'] != null) {
      return response['username'];
    } else {
      throw Exception("Invalid response: No username found");
    }
  } catch (e) {
    throw Exception("Failed to fetch username: $e");
  }
}

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Post> _posts = [];
  Map<int, String> _users = {};
  Map<int, List<Comment>> postComments = {};
  Map<String, String> _restaurants = {};
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isFetching = false;

  // To store the username
  String currentUsername = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      initializePage(request); // Fetch username and data
    });
  }

  // --------------------------------------------------------
  // INITIALIZE PAGE (FETCH USERNAME AND DATA)
  // --------------------------------------------------------
  Future<void> initializePage(CookieRequest request) async {
    try {
      setState(() => _isLoading = true);

      // Fetch the current username
      currentUsername = await fetchUsername(request);

      // Fetch other data
      await fetchData(request);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing page: $e';
        _isLoading = false;
      });
    }
  }

  // --------------------------------------------------------
  // FETCH DATA (POSTS, COMMENTS, USERS, RESTAURANTS)
  // --------------------------------------------------------
  Future<void> fetchData(CookieRequest request) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      // Fetch posts
      final postResponse = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/post_json/',
      );
      List<dynamic> postData = postResponse;

      // Fetch comments
      final commentResponse = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/comment_json/',
      );
      List<dynamic> commentData = commentResponse;

      // Fetch user list
      final userResponse = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/get_all_users/',
      );
      List<dynamic> userData = userResponse['users'];

      // Fetch restaurants
      final restaurantResponse = await request.get(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/restaurant_json/',
      );
      List<dynamic> restaurantData = restaurantResponse;

      // Map userId to username
      Map<int, String> fetchedUsers = {};
      for (var user in userData) {
        int userId = user['id'];
        String username = user['username'];
        fetchedUsers[userId] = username;
      }

      // Convert post data to Post objects
      List<Post> fetchedPosts =
          postData.map((item) => Post.fromJson(item)).toList();

      // Map postId to list of Comments
      Map<int, List<Comment>> commentsMap = {};
      for (var item in commentData) {
        Comment comment = Comment.fromJson(item);
        if (comment.fields.post != null) {
          commentsMap.putIfAbsent(comment.fields.post!, () => []).add(comment);
        }
      }

      // Map restaurant ID to restaurant name
      Map<String, String> fetchedRestaurants = {};
      for (var item in restaurantData) {
        String restaurantId = item['pk'].toString();
        String restaurantName = item['fields']['nama'];
        fetchedRestaurants[restaurantId] = restaurantName;
      }

      setState(() {
        _users = fetchedUsers;
        _posts = fetchedPosts;
        postComments = commentsMap;
        _restaurants = fetchedRestaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _isLoading = false;
      });
    } finally {
      _isFetching = false;
    }
  }

  // --------------------------------------------------------
  // REFRESH DATA
  // --------------------------------------------------------
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final request = context.read<CookieRequest>();
    await initializePage(request);
  }

  // --------------------------------------------------------
  // BUILD WIDGET TREE
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUsername.isNotEmpty
              ? "Welcome, $currentUsername!"
              : "Jelajahi Makanan di Surabaya!",
        ),
        backgroundColor: Colors.orange.shade800,
        centerTitle: true,
      ),
      drawer: const LeftDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : Column(
                  children: [
                    // ---------------------------------------
                    // Header Section
                    // ---------------------------------------
                    Container(
                      width: double.infinity,
                      color: Colors.orange.shade100,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Jelajahi Makanan di Surabaya!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Berbagi cerita bersama kulineran di Surabaya!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to Post Form Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CreatePostPage()),
                              ).then((value) => _refreshData());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: const Text(
                              "Posting di Forum",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ---------------------------------------
                    // Posts List View
                    // ---------------------------------------
                    Expanded(child: _buildPostListView()),
                  ],
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
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 14, color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Coba Lagi"),
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
          final username = _users[post.fields.user] ?? 'Unknown User';

          // Restaurant name (if any)
          final restaurantName = post.fields.restaurant != null
              ? _restaurants[post.fields.restaurant] ?? 'Unknown Restaurant'
              : null;

          return PostCard(
            post: post,
            comments: comments,
            username: username,
            onPostUpdated: _refreshData,
            currentUsername: currentUsername,
            restaurantName: restaurantName,
            usersMap: _users, // Pass the users map to PostCard
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// UTILITY: sharePost (you can still adapt this to actually copy link, etc.)
// ---------------------------------------------------------------------------
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
  final String username; // Display name of the post owner
  final VoidCallback onPostUpdated;
  final String currentUsername; // Username of the currently logged-in user
  final String? restaurantName;
  final Map<int, String> usersMap; // Map of userId to username

  const PostCard({
    Key? key,
    required this.post,
    required this.comments,
    required this.username,
    required this.onPostUpdated,
    required this.currentUsername,
    required this.restaurantName,
    required this.usersMap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool showComments = false;
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.fields.likeCount;
  }

  // --------------------------------------------------------
  // TOGGLE LIKE
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
          const SnackBar(content: Text("Post berhasil dihapus!")),
        );
        widget.onPostUpdated(); // Refresh the posts list
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
  // POST COMMENT
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
        // Add the new comment to the local list
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
    bool canDeletePost = (widget.username == widget.currentUsername);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Card(
        // White card on top of grey background
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------
              // Top Row: Profile icon + name/date (left), Delete button (right if canDelete)
              // ---------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile icon
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),

                  const SizedBox(width: 8),

                  // Username & date (left)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(post.fields.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Delete button on the right if user owns the post
                  if (canDeletePost)
                    IconButton(
                      onPressed: deletePost,
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),

              // ---------------------------------------
              // Restaurant name (if present)
              // ---------------------------------------
              if (widget.restaurantName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.restaurantName!,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                ),

              // ---------------------------------------
              // Post text
              // ---------------------------------------
              if (post.fields.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  post.fields.text,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],

              // ---------------------------------------
              // Post image (if any)
              // ---------------------------------------
              if (post.fields.image != null && post.fields.image!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.network(post.fields.image!),
                ),

              const SizedBox(height: 8),

              // ---------------------------------------
              // Action row: Like, Comment, Share, Report
              // ---------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Evenly space icons
                children: [
                  IconButton(
                    onPressed: toggleLike,
                    icon: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      color: isLiked ? Colors.blue : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      showComments = !showComments;
                    }),
                    icon: const Icon(Icons.comment_outlined),
                  ),
                  IconButton(
                    onPressed: () => sharePost(context),
                    icon: const Icon(Icons.share_outlined),
                  ),
                  IconButton(
                    onPressed: _showReportDialog, // Call the dialog function
                    icon: const Icon(Icons.flag_outlined, color: Colors.red),
                  ),
                ],
              ),

              // ---------------------------------------
              // Comments Section with Divider
              // ---------------------------------------
              if (showComments) ...[
                const Divider(),
                _buildCommentsSection(comments),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // COMMENTS SECTION
  // --------------------------------------------------------
  Widget _buildCommentsSection(List<Comment> comments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...comments.map((c) => _buildCommentItem(c)).toList(),
        const SizedBox(height: 8),
        _buildCommentInput(),
      ],
    );
  }

  // --------------------------------------------------------
  // BUILD SINGLE COMMENT ITEM
  // --------------------------------------------------------
 Widget _buildCommentItem(Comment comment) {
  String commenterUsername =
      widget.usersMap[comment.fields.user] ?? 'Unknown User';
  bool canEditComment = (commenterUsername == widget.currentUsername);

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile icon for commenter
        const CircleAvatar(
          radius: 12,
          backgroundColor: Colors.orange,
          child: Icon(Icons.person, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username in bold
              Text(
                "$commenterUsername: ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              // Comment text
              Expanded(
                child: Text(
                  comment.fields.text,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        // Edit icon (blue) if user can edit
        if (canEditComment)
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.blue,
              size: 20,
            ),
            onPressed: () => _editCommentDialog(comment),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    ),
  );
}

  // --------------------------------------------------------
  // COMMENT INPUT
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
  // EDIT COMMENT LOGIC
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
  // FORMAT DATE
  // --------------------------------------------------------
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // --------------------------------------------------------
  // REPORT POST
  // --------------------------------------------------------
  Future<void> reportPost(String reason) async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.post(
        'https://joshua-montolalu-golekmakanrek.pbp.cs.ui.ac.id/forum/report_post_flutter/',
        {
          'post_id': widget.post.pk.toString(),
          'reason': reason,
        },
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  response['message'] ?? "Postingan berhasil dilaporkan!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal melaporkan: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error melaporkan post: $e")),
      );
    }
  }

  // --------------------------------------------------------
  // SHOW REPORT DIALOG
  // --------------------------------------------------------
  void _showReportDialog() {
    String selectedReason = "Konten Tidak Pantas"; // Default selected reason
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Laporkan Postingan"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateSB) {
              return DropdownButton<String>(
                value: selectedReason,
                isExpanded: true,
                items: <String>[
                  "Konten Tidak Pantas",
                  "Spam atau Iklan",
                  "Bahasa Kasar atau Menyinggung",
                  "Misinformasi",
                  "Topik Tidak Relevan"
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newVal) {
                  setStateSB(() {
                    selectedReason = newVal ?? "Konten Tidak Pantas";
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                reportPost(selectedReason); // Call the report function with the selected reason
              },
              child: const Text("Kirim"),
            ),
          ],
        );
      },
    );
  }
}
