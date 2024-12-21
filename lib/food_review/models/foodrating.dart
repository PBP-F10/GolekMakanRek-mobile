// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

class Welcome {
    String model;
    String pk;
    Fields fields;

    Welcome({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
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
    String deskripsiFood;
    int score;
    String comment;
    DateTime waktuComment;

    Fields({
        required this.user,
        required this.deskripsiFood,
        required this.score,
        required this.comment,
        required this.waktuComment,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        deskripsiFood: json["deskripsi_food"],
        score: json["score"],
        comment: json["comment"],
        waktuComment: DateTime.parse(json["waktu_comment"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "deskripsi_food": deskripsiFood,
        "score": score,
        "comment": comment,
        "waktu_comment": waktuComment.toIso8601String(),
    };
}