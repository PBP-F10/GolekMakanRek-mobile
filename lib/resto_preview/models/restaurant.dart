// To parse this JSON data, do
//
//     final restaurant = restaurantFromJson(jsonString);
import 'dart:convert';
List<Restaurant> restaurantFromJson(String str) => List<Restaurant>.from(json.decode(str).map((x) => Restaurant.fromJson(x)));
String restaurantToJson(List<Restaurant> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
class Restaurant {
    Model model;
    String pk;
    Fields fields;
    Restaurant({
        required this.model,
        required this.pk,
        required this.fields,
    });
    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
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
enum Model {
    MAIN_RESTAURANT
}
final modelValues = EnumValues({
    "main.restaurant": Model.MAIN_RESTAURANT
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