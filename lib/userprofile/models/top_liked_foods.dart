// To parse this JSON data, do
//
//     final topLikedFoods = topLikedFoodsFromJson(jsonString);

import 'dart:convert';

TopLikedFoods topLikedFoodsFromJson(String str) => TopLikedFoods.fromJson(json.decode(str));

String topLikedFoodsToJson(TopLikedFoods data) => json.encode(data.toJson());

class TopLikedFoods {
    List<TopLikedFood> topLikedFoods;

    TopLikedFoods({
        required this.topLikedFoods,
    });

    factory TopLikedFoods.fromJson(Map<String, dynamic> json) => TopLikedFoods(
        topLikedFoods: List<TopLikedFood>.from(json["top_liked_foods"].map((x) => TopLikedFood.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "top_liked_foods": List<dynamic>.from(topLikedFoods.map((x) => x.toJson())),
    };
}

class TopLikedFood {
    String id;
    String nama;
    String kategori;
    int harga;
    int diskon;
    int hargaSetelahDiskon;
    int averageRating;
    int likeCount;

    TopLikedFood({
        required this.id,
        required this.nama,
        required this.kategori,
        required this.harga,
        required this.diskon,
        required this.hargaSetelahDiskon,
        required this.averageRating,
        required this.likeCount,
    });

    factory TopLikedFood.fromJson(Map<String, dynamic> json) => TopLikedFood(
        id: json["id"],
        nama: json["nama"],
        kategori: json["kategori"],
        harga: json["harga"],
        diskon: json["diskon"],
        hargaSetelahDiskon: json["harga_setelah_diskon"],
        averageRating: json["average_rating"],
        likeCount: json["like_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "kategori": kategori,
        "harga": harga,
        "diskon": diskon,
        "harga_setelah_diskon": hargaSetelahDiskon,
        "average_rating": averageRating,
        "like_count": likeCount,
    };
}