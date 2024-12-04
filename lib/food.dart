// To parse this JSON data, do
//
//     final food = foodFromJson(jsonString);

import 'dart:convert';

List<Food> foodFromJson(String str) => List<Food>.from(json.decode(str).map((x) => Food.fromJson(x)));

String foodToJson(List<Food> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Food {
    Model model;
    String pk;
    Fields fields;

    Food({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Food.fromJson(Map<String, dynamic> json) => Food(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String nama;
    String kategori;
    int harga;
    int diskon;
    String deskripsi;
    String restoran;

    Fields({
        required this.nama,
        required this.kategori,
        required this.harga,
        required this.diskon,
        required this.deskripsi,
        required this.restoran,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        nama: json["nama"],
        kategori: json["kategori"],
        harga: json["harga"],
        diskon: json["diskon"],
        deskripsi: json["deskripsi"],
        restoran: json["restoran"],
    );

    Map<String, dynamic> toJson() => {
        "nama": nama,
        "kategori": kategori,
        "harga": harga,
        "diskon": diskon,
        "deskripsi": deskripsi,
        "restoran": restoran,
    };
}

enum Model {
    MAIN_FOOD
}

final modelValues = EnumValues({
    "main.food": Model.MAIN_FOOD
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
