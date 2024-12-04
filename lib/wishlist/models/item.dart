// To parse this JSON data, do
//
//     final wishlist = wishlistFromJson(jsonString);

import 'dart:convert';
import 'package:golekmakanrek_mobile/wishlist/models/food.dart';

List<Wishlist> wishlistFromJson(String str) => List<Wishlist>.from(json.decode(str).map((x) => Wishlist.fromJson(x)));

String wishlistToJson(List<Wishlist> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Wishlist {
    String model;
    int pk;
    Fields fields;

    Wishlist({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Wishlist.fromJson(Map<String, dynamic> json) => Wishlist(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int user;
    String item;
    late Food food;

    Fields({
        required this.user,
        required this.item,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        item: json['item'],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "item": item,
    };
}
