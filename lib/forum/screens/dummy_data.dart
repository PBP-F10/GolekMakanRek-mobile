// lib/dummy_data.dart

import 'package:golekmakanrek_mobile/forum/models/post.dart';
import 'package:golekmakanrek_mobile/forum/models/comment.dart';
import 'package:golekmakanrek_mobile/forum/models/like.dart';
import 'package:golekmakanrek_mobile/forum/models/report.dart';

// Dummy Posts
List<Post> dummyPosts = [
  Post(
    model: "forum.post",
    pk: 1,
    fields: PostFields(
      user: 1,
      text: "Halo! Ini contoh post pertama.",
      image: "",
      likeCount: 5,
      commentCount: 2,
      shareCount: 0,
      reportCount: 0,
      createdAt: DateTime(2024, 12, 19, 14, 30),
      restaurant: "Angkringan Abas Krian",
    ),
  ),
  Post(
    model: "forum.post",
    pk: 2,
    fields: PostFields(
      user: 2,
      text: "Ini adalah post kedua dari admin.",
      image: "https://via.placeholder.com/150",
      likeCount: 10,
      commentCount: 3,
      shareCount: 1,
      reportCount: 0,
      createdAt: DateTime(2024, 12, 18, 10, 0),
      restaurant: "",
    ),
  ),
];

// Dummy Comments
List<Comment> dummyComments = [
  Comment(
    model: "forum.comment",
    pk: 1,
    fields: CommentFields(
      post: 1,
      user: 2,
      text: "Komentar pertama!",
      createdAt: DateTime.now(),
    ),
  ),
  Comment(
    model: "forum.comment",
    pk: 2,
    fields: CommentFields(
      post: 1,
      user: 3,
      text: "Komentar kedua!",
      createdAt: DateTime.now(),
    ),
  ),
  Comment(
    model: "forum.comment",
    pk: 3,
    fields: CommentFields(
      post: 2,
      user: 4,
      text: "Komentar dari admin!",
      createdAt: DateTime.now(),
    ),
  ),
  Comment(
    model: "forum.comment",
    pk: 4,
    fields: CommentFields(
      post: 2,
      user: 5,
      text: "Komentar tambahan!",
      createdAt: DateTime.now(),
    ),
  ),
];

// Dummy Likes
List<Like> dummyLikes = [
  Like(
    model: "forum.like",
    pk: 1,
    fields: LikeFields(
      post: 1,
      user: 1,
      createdAt: DateTime.now(),
    ),
  ),
  Like(
    model: "forum.like",
    pk: 2,
    fields: LikeFields(
      post: 2,
      user: 2,
      createdAt: DateTime.now(),
    ),
  ),
];

// Dummy Reports
List<Report> dummyReports = [
  Report(
    model: "forum.report",
    pk: 1,
    fields: ReportFields(
      post: 2,
      reportedBy: 3,
      reason: "Spam atau Iklan",
      createdAt: DateTime.now(),
    ),
  ),
];