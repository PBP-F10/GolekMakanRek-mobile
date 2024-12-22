// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
    String status;
    int count;
    List<Wishlist> wishlist;

    Welcome({
        required this.status,
        required this.count,
        required this.wishlist,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        status: json["status"],
        count: json["count"],
        wishlist: List<Wishlist>.from(json["wishlist"].map((x) => Wishlist.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "count": count,
        "wishlist": List<dynamic>.from(wishlist.map((x) => x.toJson())),
    };
}

class Wishlist {
    String wishlistId;
    Food food;

    Wishlist({
        required this.wishlistId,
        required this.food,
    });

    factory Wishlist.fromJson(Map<String, dynamic> json) => Wishlist(
        wishlistId: json["wishlist_id"],
        food: Food.fromJson(json["food"]),
    );

    Map<String, dynamic> toJson() => {
        "wishlist_id": wishlistId,
        "food": food.toJson(),
    };
}

class Food {
    String id;
    String name;
    String category;
    String description;
    int originalPrice;
    int discountPercentage;
    int discountedPrice;
    double averageRating;
    Restaurant restaurant;

    Food({
        required this.id,
        required this.name,
        required this.category,
        required this.description,
        required this.originalPrice,
        required this.discountPercentage,
        required this.discountedPrice,
        required this.averageRating,
        required this.restaurant,
    });

    factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json["id"],
        name: json["name"],
        category: json["category"],
        description: json["description"],
        originalPrice: json["original_price"],
        discountPercentage: json["discount_percentage"],
        discountedPrice: json["discounted_price"],
        averageRating: json["average_rating"]?.toDouble(),
        restaurant: Restaurant.fromJson(json["restaurant"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category,
        "description": description,
        "original_price": originalPrice,
        "discount_percentage": discountPercentage,
        "discounted_price": discountedPrice,
        "average_rating": averageRating,
        "restaurant": restaurant.toJson(),
    };
}

class Restaurant {
    String id;
    String name;
    String category;
    String description;

    Restaurant({
        required this.id,
        required this.name,
        required this.category,
        required this.description,
    });

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json["name"],
        category: json["category"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category,
        "description": description,
    };
}
