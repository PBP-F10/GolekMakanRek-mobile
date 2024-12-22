// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'dart:convert';

List<Comment> commentFromJson(String str) => List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentToJson(List<Comment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Comment {
    String model;
    int pk;
    CommentFields fields;

    Comment({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        model: json["model"],
        pk: json["pk"],
        fields: CommentFields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class CommentFields {
    int post;
    int user;
    String text;
    DateTime createdAt;

    CommentFields({
        required this.post,
        required this.user,
        required this.text,
        required this.createdAt,
    });

    factory CommentFields.fromJson(Map<String, dynamic> json) => CommentFields(
        post: json["post"],
        user: json["user"],
        text: json["text"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "post": post,
        "user": user,
        "text": text,
        "created_at": createdAt.toIso8601String(),
    };
}