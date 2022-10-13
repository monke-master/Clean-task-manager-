import 'package:flutter/foundation.dart';

class DataResponse {

  int statusCode;
  Map<String, dynamic> data;

  DataResponse({required this.data, required this.statusCode});

  @override
  int get hashCode => Object.hash(statusCode, data);

  @override
  bool operator ==(Object other) =>
      other is DataResponse &&
      other.statusCode == statusCode &&
      mapEquals(other.data, data);
}