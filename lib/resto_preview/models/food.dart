// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);
class Food {
    String model;
    String pk;
    Fields fields;
    Food({
        required this.model,
        required this.pk,
        required this.fields,
    });
    factory Food.fromJson(Map<String, dynamic> json) => Food(
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