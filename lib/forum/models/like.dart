// To parse this JSON data, do
//
//     final like = likeFromJson(jsonString);

import 'dart:convert';

List<Like> likeFromJson(String str) => List<Like>.from(json.decode(str).map((x) => Like.fromJson(x)));

String likeToJson(List<Like> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Like {
    String model;
    int pk;
    LikeFields fields;

    Like({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Like.fromJson(Map<String, dynamic> json) => Like(
        model: json["model"],
        pk: json["pk"],
        fields: LikeFields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class LikeFields {
    int post;
    int user;
    DateTime createdAt;

    LikeFields({
        required this.post,
        required this.user,
        required this.createdAt,
    });

    factory LikeFields.fromJson(Map<String, dynamic> json) => LikeFields(
        post: json["post"],
        user: json["user"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "post": post,
        "user": user,
        "created_at": createdAt.toIso8601String(),
    };
}