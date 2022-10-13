import 'package:localstore/localstore.dart';
import 'package:task_manager_arch/helpers/string_helper.dart';
import 'package:task_manager_arch/models/data_response.dart';

class LocalDatabase {

  static final LocalDatabase _localDatabase = LocalDatabase._internal();
  late Localstore _database;

  LocalDatabase._internal();

  factory LocalDatabase() {
    return _localDatabase;
  }

  void init() {
    _database = Localstore.instance;
  }

  // Методы для работы с конфигурацией
  Future<void> putConfig(Map<String, dynamic> data) async {
    var oldData = await getConfig();
    if (oldData.statusCode == 200) {
      for (String key in data.keys) {
        oldData.data[key] = data[key];
      }
      data = oldData.data;
    }
    await _database.collection('config').doc('1').set(data);
  }

  Future<DataResponse> getConfig() async {
    var result = await _database.collection('config').doc('1').get();
    if (result != null) {
      return DataResponse(data: result, statusCode: 200);
    }
    return DataResponse(data: {"body": "There is no config "}, statusCode: 404);
  }

  Future<void> deleteConfig() async {
    await _database.collection('config').doc('1').delete();
  }

  // Методы для работы с пользователем
  Future<void> putUser(String userId, Map<String, dynamic> data) async {
    DataResponse oldData = await getUser(userId);
    if (oldData.statusCode == 200) {
      for (String key in data.keys) {
        oldData.data[key] = data[key];
      }
      data = oldData.data;
    }
    await _database.collection('user').doc(userId).set(data);
  }

  Future<DataResponse> getUser(String userId) async {
    Map<String, dynamic>? result = await _database.collection('user').doc(userId).get();
    if (result != null) {
      result['id'] = userId;
      return DataResponse(data: result, statusCode: 200);
    }
    return DataResponse(data: {"body": "User not found"}, statusCode: 404);
  }

  Future<void> deleteUser(String userId) async {
    await _database.collection('user').doc(userId).delete();
  }

  // Методы для работы с категориями
  Future<void> putCategory(String categoryId, Map<String, dynamic> data) async {
    DataResponse oldData = await getCategory(categoryId);
    if (oldData.statusCode == 200) {
      for (String key in data.keys) {
        oldData.data[key] = data[key];
      }
      data = oldData.data;
    }
    await _database.collection('categories').doc(categoryId).set(data);
  }

  Future<DataResponse> getCategory(String categoryId) async {
    Map<String, dynamic>? result = await _database.collection('categories').doc(categoryId).get();
    if (result != null) {
      result['category_id'] = categoryId;
      return DataResponse(data: result, statusCode: 200);
    }
    return DataResponse(data: {"body": "Category not found"}, statusCode: 404);
  }

  Future<DataResponse> getCategoriesList(String userId) async {
    Map<String, dynamic>? categories = await _database.collection('categories').get();
    if (categories == null) {
      return DataResponse(data: {"body": "User not found"}, statusCode: 404);
    }

    Map<String, dynamic> result = {};
    for (String categoryId in categories.keys) {
      if (categories[categoryId]['user_id'] == userId) {
        result[StringHelper.getId(categoryId)] = categories[categoryId];
      }
    }

    if (result.isEmpty) {
      return DataResponse(data: {"body": "User not found"}, statusCode: 404);
    }
    return DataResponse(data: result, statusCode: 200);
  }

  Future<DataResponse> deleteCategory(String categoryId) async {
    await _database.collection('categories').doc(categoryId).delete();
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }


  // Методы для работы с задачами
  Future<void> putTask(String taskId, Map<String, dynamic> data) async {
    DataResponse oldData = await getTask(taskId);
    if (oldData.statusCode == 200) {
      for (String key in data.keys) {
        oldData.data[key] = data[key];
      }
      data = oldData.data;
    }
    await _database.collection('tasks').doc(taskId).set(data);
  }

  Future<DataResponse> getTask(String taskId) async {
    Map<String, dynamic>? result = await _database.collection('tasks').doc(taskId).get();
    if (result != null) {
      result['task_id'] = taskId;
      return DataResponse(data: result, statusCode: 200);
    }
    return DataResponse(data: {"body": "Task not found"}, statusCode: 404);
  }

  Future<DataResponse> getUserTasks(String userId) async {
    Map<String, dynamic>? tasks = await _database.collection('tasks').get();
    if (tasks == null) {
      return DataResponse(data: {"body": "User not found"}, statusCode: 404);
    }

    Map<String, dynamic> result = {};
    for (String taskId in tasks.keys) {
      if (tasks[taskId]['user_id'] == userId) {
        result[StringHelper.getId(taskId)] = tasks[taskId];
      }
    }

    if (result.isEmpty) {
      return DataResponse(data: {"body": "User not found"}, statusCode: 404);
    }
    return DataResponse(data: result, statusCode: 200);
  }

  Future<DataResponse> getCategoryTasks(String categoryId) async {
    Map<String, dynamic>? tasks = await _database.collection('tasks').get();
    if (tasks == null) {
      return DataResponse(data: {"body": "User not found"}, statusCode: 404);
    }

    Map<String, dynamic> result = {};
    for (String taskId in tasks.keys) {
      if (tasks[taskId]['category_id'] == categoryId) {
        result[StringHelper.getId(taskId)] = tasks[taskId];
      }
    }

    if (result.isEmpty) {
      return DataResponse(data: {"body": "Category not found"}, statusCode: 404);
    }
    return DataResponse(data: result, statusCode: 200);
  }

  Future<void> deleteTask(String taskId) async {
    await _database.collection('tasks').doc(taskId).delete();
  }

}


