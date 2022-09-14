import 'package:flutter/material.dart';

class Task {

  String taskId;
  String categoryId;
  String userId;
  String title;
  DateTime date;
  DateTime creationDate;
  bool completed;
  int emailed;
  int repeating;

  Task({required this.taskId, required this.userId, required this.categoryId,
        required this.title, required this.date, required this.creationDate,
        required this.completed, required this.emailed, required this.repeating});


  @override
  int hash() => hashValues(taskId, categoryId, userId, title, date,
                           creationDate, completed, repeating, emailed);

  @override
  bool operator == (Object object) =>
      object is Task &&
          object.taskId == taskId &&
          object.categoryId == categoryId &&
          object.userId == userId &&
          object.title == title &&
          object.date == date &&
          object.creationDate == creationDate &&
          object.completed == completed &&
          object.repeating == repeating &&
          object.emailed == emailed;
}