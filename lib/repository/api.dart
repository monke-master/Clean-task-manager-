import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:task_manager_arch/models/data_response.dart';

class Api {

  final String _base ='http://localhost:8080';

  // User methods
  Future<DataResponse> addUser(String userId,
      Map<String, dynamic> userData) async {
    var uri = Uri.parse("$_base/user/$userId");
    try {
      var response = await http.post(uri, body: userData);
      return DataResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> getUser(String userId) async {
    var uri = Uri.parse("$_base/user/$userId");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return DataResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> getUserByEmail(String email) async {
    var uri = Uri.parse('$_base/user/email/$email');
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return DataResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
      }
    }

  Future<DataResponse> updateUser(String userId,
      Map<String, dynamic> userData) async {
    var uri = Uri.parse("$_base/user/$userId");
    try {
      var response = await http.put(uri, body: userData);
      return DataResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> deleteUser(String userId) async {
    var uri = Uri.parse("$_base/user/$userId");
    try {
      var response = await http.delete(uri);
      return DataResponse(data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> getCategory(String categoryId) async {
    var uri = Uri.parse("$_base/category/$categoryId");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return DataResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> getCategoriesList(String userId) async {
    var uri = Uri.parse("$_base/user/$userId/categories");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return DataResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> addCategory(String categoryId,
      Map<String, dynamic> categoryData) async {
    var uri = Uri.parse("$_base/category/$categoryId");
    try {
      var response = await http.post(uri, body: categoryData);
      return DataResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> updateCategory(String categoryId,
      Map<String, dynamic> categoryData) async {
    var uri = Uri.parse("$_base/category/$categoryId");
    try {
      var response = await http.put(uri, body: categoryData);
      return DataResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> deleteCategory(String categoryId) async {
    var uri = Uri.parse("$_base/category/$categoryId");
    try {
      var response = await http.delete(uri);
      return DataResponse(data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  // Task methods

  Future<DataResponse> getTask(String taskId) async {
    var uri = Uri.parse("$_base/task/$taskId");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return DataResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> getUserTasks(String userId) async {
    var uri = Uri.parse("$_base/user/$userId/tasks");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return DataResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> getCategoryTasks(String categoryId) async {
    var uri = Uri.parse("$_base/category/$categoryId/tasks");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return DataResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> addTask(String taskId,
      Map<String, dynamic> taskData) async {
    var uri = Uri.parse("$_base/task/$taskId");
    try {
      var response = await http.post(uri, body: taskData);
      return DataResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> updateTask(String taskId,
      Map<String, dynamic> taskData) async {
    var uri = Uri.parse("$_base/task/$taskId");
    try {
      var response = await http.put(uri, body: taskData);
      return DataResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<DataResponse> deleteTask(String taskId) async {
    var uri = Uri.parse("$_base/task/$taskId");
    try {
      var response = await http.delete(uri);
      return DataResponse(data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return DataResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return DataResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }
}
