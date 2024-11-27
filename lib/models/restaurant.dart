import 'dart:convert';

List<Restaurant> restaurantFromJson(String str) => List<Restaurant>.from(json.decode(str).map((x) => Restaurant.fromJson(x)));

String restaurantToJson(List<Restaurant> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Restaurant {
    String model;
    String pk;
    Fields fields;

    Restaurant({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
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
    String nama;
    String kategori;
    String deskripsi;

    Fields({
        required this.nama,
        required this.kategori,
        required this.deskripsi,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        nama: json["nama"],
        kategori: json["kategori"],
        deskripsi: json["deskripsi"],
    );

    Map<String, dynamic> toJson() => {
        "nama": nama,
        "kategori": kategori,
        "deskripsi": deskripsi,
    };
}