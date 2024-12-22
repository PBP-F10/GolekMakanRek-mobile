// To parse this JSON data, do
//
//     final report = reportFromJson(jsonString);

import 'dart:convert';

List<Report> reportFromJson(String str) => List<Report>.from(json.decode(str).map((x) => Report.fromJson(x)));

String reportToJson(List<Report> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Report {
    String model;
    int pk;
    ReportFields fields;

    Report({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Report.fromJson(Map<String, dynamic> json) => Report(
        model: json["model"],
        pk: json["pk"],
        fields: ReportFields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class ReportFields {
    int post;
    int reportedBy;
    String reason;
    DateTime createdAt;

    ReportFields({
        required this.post,
        required this.reportedBy,
        required this.reason,
        required this.createdAt,
    });

    factory ReportFields.fromJson(Map<String, dynamic> json) => ReportFields(
        post: json["post"],
        reportedBy: json["reported_by"],
        reason: json["reason"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "post": post,
        "reported_by": reportedBy,
        "reason": reason,
        "created_at": createdAt.toIso8601String(),
    };
}
