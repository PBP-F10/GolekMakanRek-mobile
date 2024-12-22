class PostList {
  final List<Post> posts;

  PostList({
    required this.posts,
  });

  factory PostList.fromJson(Map<String, dynamic> json) => PostList(
        posts: List<Post>.from(json['posts'].map((x) => Post.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'posts': List<dynamic>.from(posts.map((x) => x.toJson())),
      };
}

class Post {
  final int id;
  final String user; // Assuming this is the username
  final String text;
  final String? image;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int reportCount;
  final DateTime createdAt;
  final String? restaurant; // Assuming this is the restaurant name
  final List<Like> likes;
  final List<Comment> comments;
  final List<Report> reports;

  Post({
    required this.id,
    required this.user,
    required this.text,
    this.image,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.reportCount,
    required this.createdAt,
    this.restaurant,
    required this.likes,
    required this.comments,
    required this.reports,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'],
        user: json['user'],
        text: json['text'],
        image: json['image'],
        likeCount: json['like_count'],
        commentCount: json['comment_count'],
        shareCount: json['share_count'],
        reportCount: json['report_count'],
        createdAt: DateTime.parse(json['created_at']),
        restaurant: json['restaurant'],
        likes: json['likes'] != null
            ? List<Like>.from(json['likes'].map((x) => Like.fromJson(x)))
            : [],
        comments: json['comments'] != null
            ? List<Comment>.from(json['comments'].map((x) => Comment.fromJson(x)))
            : [],
        reports: json['reports'] != null
            ? List<Report>.from(json['reports'].map((x) => Report.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'text': text,
        'image': image,
        'like_count': likeCount,
        'comment_count': commentCount,
        'share_count': shareCount,
        'report_count': reportCount,
        'created_at': createdAt.toIso8601String(),
        'restaurant': restaurant,
        'likes': List<dynamic>.from(likes.map((x) => x.toJson())),
        'comments': List<dynamic>.from(comments.map((x) => x.toJson())),
        'reports': List<dynamic>.from(reports.map((x) => x.toJson())),
      };
}

class Like {
  final int id;
  final int postId;
  final int userId;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) => Like(
        id: json['id'],
        postId: json['post_id'],
        userId: json['user_id'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
      };
}

class Comment {
  final int id;
  final int postId;
  final int userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'],
        postId: json['post_id'],
        userId: json['user_id'],
        text: json['text'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'user_id': userId,
        'text': text,
        'created_at': createdAt.toIso8601String(),
      };
}

class Report {
  final int id;
  final int postId;
  final int reportedById;
  final String reason;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.postId,
    required this.reportedById,
    required this.reason,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'],
        postId: json['post_id'],
        reportedById: json['reported_by_id'],
        reason: json['reason'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'reported_by_id': reportedById,
        'reason': reason,
        'created_at': createdAt.toIso8601String(),
      };
}