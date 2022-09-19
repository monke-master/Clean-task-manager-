import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:task_manager_arch/repository/repository_response.dart';

class Api {

  final String _base ='http://localhost:8080';

  // User methods
  Future<RepositoryResponse> addUser(String userId,
      Map<String, dynamic> userData) async {
    var uri = Uri.parse("$_base/user/$userId");
    try {
      var response = await http.post(uri, body: userData);
      return RepositoryResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> getUser(String userId) async {
    var uri = Uri.parse("$_base/user/$userId");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return RepositoryResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> getUserByEmail(String email) async {
    var uri = Uri.parse('$_base/user/email/$email');
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return RepositoryResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
      }
    }

  Future<RepositoryResponse> updateUser(String userId,
      Map<String, dynamic> userData) async {
    var uri = Uri.parse("$_base/user/$userId");
    try {
      var response = await http.put(uri, body: userData);
      return RepositoryResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> deleteUser(String userId) async {
    var uri = Uri.parse("$_base/user/$userId");
    try {
      var response = await http.delete(uri);
      return RepositoryResponse(data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> getCategory(String categoryId) async {
    var uri = Uri.parse("$_base/category/$categoryId");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return RepositoryResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> getCategoriesList(String userId) async {
    var uri = Uri.parse("$_base/user/$userId/categories");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return RepositoryResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> addCategory(String categoryId,
      Map<String, dynamic> categoryData) async {
    var uri = Uri.parse("$_base/category/$categoryId");
    try {
      var response = await http.post(uri, body: categoryData);
      return RepositoryResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> updateCategory(String categoryId,
      Map<String, dynamic> categoryData) async {
    var uri = Uri.parse("$_base/category/$categoryId");
    try {
      var response = await http.put(uri, body: categoryData);
      return RepositoryResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> deleteCategory(String categoryId) async {
    var uri = Uri.parse("$_base/category/$categoryId");
    try {
      var response = await http.delete(uri);
      return RepositoryResponse(data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  // Task methods

  Future<RepositoryResponse> getTask(String taskId) async {
    var uri = Uri.parse("$_base/task/$taskId");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return RepositoryResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> getUserTasks(String userId) async {
    var uri = Uri.parse("$_base/user/$userId/tasks");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return RepositoryResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> getCategoryTasks(String categoryId) async {
    var uri = Uri.parse("$_base/category/$categoryId/tasks");
    try {
      var response = await http.get(uri);
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        data['body'] = response.body;
      }
      return RepositoryResponse(data: data, statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> addTask(String taskId,
      Map<String, dynamic> taskData) async {
    var uri = Uri.parse("$_base/task/$taskId");
    try {
      var response = await http.post(uri, body: taskData);
      return RepositoryResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> updateTask(String taskId,
      Map<String, dynamic> taskData) async {
    var uri = Uri.parse("$_base/task/$taskId");
    try {
      var response = await http.put(uri, body: taskData);
      return RepositoryResponse(
          data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }

  Future<RepositoryResponse> deleteTask(String taskId) async {
    var uri = Uri.parse("$_base/task/$taskId");
    try {
      var response = await http.delete(uri);
      return RepositoryResponse(data: {'body': response.body},
          statusCode: response.statusCode);
    } on SocketException {
      return RepositoryResponse(
          data: {'body': "No network connection"},
          statusCode: 0);
    } catch (error) {
      return RepositoryResponse(
          data: {'body': error},
          statusCode: -1);
    }
  }
}






