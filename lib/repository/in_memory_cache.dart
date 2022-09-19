import 'package:task_manager_arch/repository/repository_response.dart';

class InMemoryCache {

  Map<String, dynamic> _user = {};
  final Map<String, Map<String, dynamic>> _categories = {};
  final Map<String, Map<String, dynamic>> _tasks = {};

  // User methods
  RepositoryResponse addUser(String userId, Map<String, dynamic> userData) {
    userData['id'] = userId;
    _user = userData;
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  RepositoryResponse getUser(String userId) {
    return RepositoryResponse(data: _user, statusCode: 200);
  }

  RepositoryResponse updateUser(Map<String, dynamic> userData) {
    _user['email'] = userData['email'];
    _user['password'] = userData['password'];
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  RepositoryResponse deleteUser() {
    _user.clear();
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  // Category methods
  RepositoryResponse addCategory(String categoryId, Map<String, dynamic> categoryData) {
    _categories[categoryId] = categoryData;
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  RepositoryResponse getCategory(String categoryId) {
    return RepositoryResponse(data: _categories[categoryId]!, statusCode: 200);
  }

  RepositoryResponse getCategoriesList() {
    return RepositoryResponse(data: _categories, statusCode: 200);
  }

  RepositoryResponse updateCategory(String categoryId, Map<String, dynamic> categoryData) {
    _categories[categoryId]!['title'] = categoryData['title'];
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  RepositoryResponse deleteCategory(String categoryId) {
    _categories.remove(categoryId);
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  // Task methods
  RepositoryResponse addTask(String taskId, Map<String, dynamic> taskData) {
    _tasks[taskId] = taskData;
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  RepositoryResponse getTask(String taskId) {
    return RepositoryResponse(data: _tasks[taskId]!, statusCode: 200);
  }

  RepositoryResponse getUserTasks() {
    return RepositoryResponse(data: _tasks, statusCode: 200);
  }

  RepositoryResponse getCategoryTasks(String categoryId) {
    Map<String, dynamic> responseData = {};
    for (String taskId in _tasks.keys) {
      if (_tasks[taskId]!['categoryId'] == categoryId) {
        responseData[taskId] = _tasks[taskId];
      }
    }
    return RepositoryResponse(data: responseData, statusCode: 200);
  }

  RepositoryResponse updateTask(String taskId, Map<String, dynamic> taskData) {
    for (String key in taskData.keys) {
      _tasks[taskId]![key] = taskData[key];
    }
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  RepositoryResponse deleteTask(String taskId) {
    _tasks.remove(taskId);
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

}