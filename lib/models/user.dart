import 'package:flutter/material.dart';

import 'category.dart';

class User {

  String id;
  String email;
  String password;
  DateTime registrationDate;
  List<Category> categories = [];

  User({required this.id, required this.email, required this.password,
    required this.registrationDate});

  @override
  int hash() => hashValues(id, email, password, registrationDate);

  @override
  bool operator == (Object object) =>
      object is User &&
      object.id == id &&
      object.email == email &&
      object.password == password &&
      object.registrationDate == registrationDate;


}