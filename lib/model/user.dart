import 'package:flutter/material.dart';

class User {
  String? userId;
  String? userName;
  String? userEmail;
  String? userPassword;
  String? userPhone;
  String? userAddress;
  String? userImage;

  User({
    this.userId,
    this.userName,
    this.userEmail,
    this.userPassword,
    this.userPhone,
    this.userAddress,
    this.userImage,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['worker_id'];
    userName = json['full_name'];
    userEmail = json['email'];
    userPassword = json['password'];
    userPhone = json['phone'];
    userAddress = json['address'];
    userImage = json['image'] ?? ""; // fallback to empty string
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['worker_id'] = userId;
    data['full_name'] = userName;
    data['email'] = userEmail;
    data['password'] = userPassword;
    data['phone'] = userPhone;
    data['address'] = userAddress;
    data['image'] = userImage;
    return data;
  }

  /// Helper method to get the ImageProvider
  ImageProvider getProfileImage(String baseUrl) {
    if ((userImage?.isNotEmpty ?? false)) {
      return NetworkImage("$baseUrl/$userImage");
    } else {
      return const AssetImage("assets/images/profile.png");
    }
  }
}
