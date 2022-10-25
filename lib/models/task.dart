import 'package:flutter/material.dart';

class Task {

  String taskId;
  String categoryId;
  String userId;
  String title;
  DateTime date;
  DateTime creationDate;
  bool completed;
  bool? emailed;
  int repeating;

  Task({required this.taskId, required this.userId, required this.categoryId,
        required this.title, required this.date, required this.creationDate,
        required this.completed, required this.emailed, required this.repeating});


  @override
  int get hashCode => Object.hash(taskId, categoryId, userId, title, date,
                           creationDate, completed, repeating, emailed);

  @override
  bool operator == (Object other) =>
      other is Task &&
          other.taskId == taskId &&
          other.categoryId == categoryId &&
          other.userId == userId &&
          other.title == title &&
          other.date == date &&
          other.creationDate == creationDate &&
          other.completed == completed &&
          other.repeating == repeating &&
          other.emailed == emailed;
}