import 'package:task_manager_arch/models/data_response.dart';

class InMemoryCache {

  Map<String, dynamic> _user = {};
  final Map<String, Map<String, dynamic>> _categories = {};
  final Map<String, Map<String, dynamic>> _tasks = {};

  // User methods
  DataResponse addUser(String userId, Map<String, dynamic> userData) {
    userData['id'] = userId;
    _user = userData;
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  DataResponse getUser(String userId) {
    return DataResponse(data: _user, statusCode: 200);
  }

  DataResponse updateUser(Map<String, dynamic> userData) {
    _user['email'] = userData['email'];
    _user['password'] = userData['password'];
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  DataResponse deleteUser() {
    _user.clear();
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  // Category methods
  DataResponse addCategory(String categoryId, Map<String, dynamic> categoryData) {
    _categories[categoryId] = categoryData;
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  DataResponse getCategory(String categoryId) {
    return DataResponse(data: _categories[categoryId]!, statusCode: 200);
  }

  DataResponse getCategoriesList() {
    return DataResponse(data: _categories, statusCode: 200);
  }

  DataResponse updateCategory(String categoryId, Map<String, dynamic> categoryData) {
    _categories[categoryId]!['title'] = categoryData['title'];
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  DataResponse deleteCategory(String categoryId) {
    _categories.remove(categoryId);
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  // Task methods
  DataResponse addTask(String taskId, Map<String, dynamic> taskData) {
    _tasks[taskId] = taskData;
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  DataResponse getTask(String taskId) {
    return DataResponse(data: _tasks[taskId]!, statusCode: 200);
  }

  DataResponse getUserTasks() {
    return DataResponse(data: _tasks, statusCode: 200);
  }

  DataResponse getCategoryTasks(String categoryId) {
    Map<String, dynamic> responseData = {};
    for (String taskId in _tasks.keys) {
      if (_tasks[taskId]!['categoryId'] == categoryId) {
        responseData[taskId] = _tasks[taskId];
      }
    }
    return DataResponse(data: responseData, statusCode: 200);
  }

  DataResponse updateTask(String taskId, Map<String, dynamic> taskData) {
    for (String key in taskData.keys) {
      _tasks[taskId]![key] = taskData[key];
    }
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  DataResponse deleteTask(String taskId) {
    _tasks.remove(taskId);
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

}