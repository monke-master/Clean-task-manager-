import 'package:flutter/material.dart';
import 'package:task_manager_arch/models/task.dart';

class Category {

  String categoryId;
  String userId;
  String title;
  DateTime creationDate;
  List<Task> tasks = [];

  Category({required this.categoryId, required this.userId, required this.title,
            required this.creationDate});

  @override
  int hash() => hashValues(categoryId, userId, title, creationDate);

  @override
  bool operator == (Object object) =>
          object is Category &&
          object.categoryId == categoryId &&
          object.userId == userId &&
          object.title == title &&
          object.creationDate == creationDate;



}