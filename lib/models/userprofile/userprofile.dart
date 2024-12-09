// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

import 'dart:convert';

UserProfile userProfileFromJson(String str) => UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
    Profile? profile;
    bool? created;

    UserProfile({
        this.profile,
        this.created,
    });

    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        profile: Profile.fromJson(json["profile"]),
        created: json["created"],
    );

    Map<String, dynamic> toJson() => {
        "profile": profile!.toJson(),
        "created": created,
    };
}

class Profile {
  String? username;
  String? description;
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? gender;
  String? location;
  String? phoneNumber;
  String? email;

  Profile({
    this.username,
    this.description,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.location,
    this.phoneNumber,
    this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        username: json["username"],
        description: json["description"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        dateOfBirth: json["date_of_birth"] != null
            ? DateTime.parse(json["date_of_birth"])
            : null, // Handle null date_of_birth
        gender: json["gender"],
        location: json["location"],
        phoneNumber: json["phone_number"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "description": description,
        "first_name": firstName,
        "last_name": lastName,
        "date_of_birth": dateOfBirth != null
            ? "${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}"
            : null, // Handle null date_of_birth safely
        "gender": gender,
        "location": location,
        "phone_number": phoneNumber,
        "email": email,
      };
}