import 'package:localstore/localstore.dart';
import 'package:task_manager_arch/helpers/string_helper.dart';
import 'package:task_manager_arch/models/data_response.dart';

// Singleton Класс для хранения данных на устройстве
// Используется библиотека LocalStore
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
  // Старые данные берутся для того, чтобы в случае редактирования они не были
  // потеряны
  Future<void> putConfig(Map<String, dynamic> data) async {
    var oldData = await getConfig();
    if (oldData != null) {
      for (String key in data.keys) {
        oldData[key] = data[key];
      }
      data = oldData;
    }
    await _database.collection('config').doc('1').set(data);
  }

  Future<Map<String, dynamic>?> getConfig() async {
    return await _database.collection('config').doc('1').get();
  }

  Future<DataResponse> deleteConfig() async {
    try {
      await _database.collection('config').doc('1').delete();
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    } catch (exception) {
      return DataResponse(data: {'body': exception}, statusCode: 500);
    }

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
    await _database.collection('users').doc(userId).set(data);
  }

  Future<DataResponse> getUser(String userId) async {
    Map<String, dynamic>? result = await _database.collection('users').doc(userId).get();
    if (result != null) {
      result['id'] = userId;
      return DataResponse(data: result, statusCode: 200);
    }
    return DataResponse(data: {"body": "User not found"}, statusCode: 404);
  }

  Future<DataResponse> deleteUser(String userId) async {
    Map<String, dynamic>? user = await _database.collection('users').doc(userId).get();
    if (user != null) {
      await _database.collection('users').doc(userId).delete();
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    } else {
      return DataResponse(data: {"body": "Task not found"}, statusCode: 404);
    }
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

  Future<Map<String, dynamic>> getCategoriesList(String userId) async {
    Map<String, dynamic>? categories = await _database.collection('categories').get();
    if (categories == null) {
      return {};
    }
    // Редактирование id
    Map<String, dynamic> result = {};
    for (String categoryId in categories.keys) {
      if (categories[categoryId]['user_id'] == userId) {
        result[StringHelper.getId(categoryId)] = categories[categoryId];
      }
    }
    return result;
  }

  Future<DataResponse> deleteCategory(String categoryId) async {
    Map<String, dynamic>? category = await _database.collection('categories').doc(categoryId).get();
    if (category != null) {
      await _database.collection('categories').doc(categoryId).delete();
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    } else {
      return DataResponse(data: {"body": "Task not found"}, statusCode: 404);
    }
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

  Future<Map<String, dynamic>> getUserTasks(String userId) async {
    Map<String, dynamic>? tasks = await _database.collection('tasks').get();
    if (tasks == null) {
      return {};
    }

    Map<String, dynamic> result = {};
    for (String taskId in tasks.keys) {
      if (tasks[taskId]['user_id'] == userId) {
        result[StringHelper.getId(taskId)] = tasks[taskId];
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> getCategoryTasks(String categoryId) async {
    Map<String, dynamic>? tasks = await _database.collection('tasks').get();
    if (tasks == null) {
      return {};
    }

    Map<String, dynamic> result = {};
    for (String taskId in tasks.keys) {
      if (tasks[taskId]['category_id'] == categoryId) {
        result[StringHelper.getId(taskId)] = tasks[taskId];
      }
    }
    return result;
  }

  Future<DataResponse> deleteTask(String taskId) async {
    Map<String, dynamic>? task = await _database.collection('tasks').doc(taskId).get();
    if (task != null) {
      await _database.collection('tasks').doc(taskId).delete();
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }
    return DataResponse(data: {"body": "Task not found"}, statusCode: 404);
  }

  Future<void> putError(Map<String, dynamic> data) async {
    Map<String, dynamic>? errorsList = await _database.collection('errors').get();
    int id = errorsList == null ? 0 : errorsList.length;
    await _database.collection('errors').doc('$id').set(data);
  }

  Future<Map<String, dynamic>> getErrorsList() async {
    Map<String, dynamic>? errorsList = await _database.collection('errors').get();
    if (errorsList == null) {
      return {};
    }

    Map<String, dynamic> result = {};
    for (String errorId in errorsList.keys) {
        result[StringHelper.getId(errorId)] = errorsList[errorId];
    }
    return result;

  }

  Future<DataResponse> deleteError(String errorId) async {
    try {
      await _database.collection('errors').doc(errorId).delete();
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    } catch (error) {
      return DataResponse(data: {"body": error.toString()}, statusCode: 200);
    }
  }


}


