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

  // Config methods
  Future<DataResponse> putConfig(Map<String, dynamic> data) async {
    await _database.collection('config').doc('1').set(data);
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  Future<DataResponse> getConfig() async {
    var result = await _database.collection('config').doc('1').get();
    if (result != null) {
      return DataResponse(data: result, statusCode: 200);
    }
    return DataResponse(data: {"body": "There is no config "}, statusCode: 404);
  }

  Future<DataResponse> deleteConfig() async {
    await _database.collection('config').doc('1').delete();
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  // User methods
  Future<DataResponse> putUser(String userId, Map<String, dynamic> data) async {
    await _database.collection('user').doc(userId).set(data);
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  Future<DataResponse> getUser(String userId) async {
    var result = await _database.collection('user').doc(userId).get();
    if (result != null) {
      return DataResponse(data: result, statusCode: 200);
    }
    return DataResponse(data: {"body": "User not found"}, statusCode: 404);
  }

  Future<DataResponse> deleteUser(String userId) async {
    await _database.collection('user').doc(userId).delete();
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  // Categories methods
  Future<DataResponse> putCategory(String categoryId, Map<String, dynamic> data) async {
    await _database.collection('categories').doc(categoryId).set(data);
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  Future<DataResponse> getCategory(String categoryId) async {
    var result = await _database.collection('categories').doc(categoryId).get();
    if (result != null) {
      return DataResponse(data: result, statusCode: 200);
    }
    return DataResponse(data: {"body": "Category not found"}, statusCode: 404);
  }

  Future<DataResponse> getCategoriesList(String userId) async {
    var categories = await _database.collection('categories').get();

    Map<String, dynamic> result = {};

    if (categories == null) {
      return DataResponse(data: {"body": "User not found"}, statusCode: 404);
    }

    for (String categoryId in categories!.keys) {
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


  // tasks methods
  Future<DataResponse> putTask(String taskId, Map<String, dynamic> data) async {
    await _database.collection('tasks').doc(taskId).set(data);
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }

  Future<DataResponse> getTask(String taskId) async {
    var result = await _database.collection('tasks').doc(taskId).get();
    if (result != null) {
      return DataResponse(data: result, statusCode: 200);
    }
    return DataResponse(data: {"body": "Task not found"}, statusCode: 404);
  }

  Future<DataResponse> getUserTasks(String userId) async {
    var tasks = await _database.collection('tasks').get();

    Map<String, dynamic> result = {};

    if (tasks == null) {
      return DataResponse(data: {"body": "User not found"}, statusCode: 404);
    }

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
    var tasks = await _database.collection('tasks').get();

    Map<String, dynamic> result = {};

    if (tasks == null) {
      return DataResponse(data: {"body": "User not found"}, statusCode: 404);
    }

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

  Future<DataResponse> deleteTask(String taskId) async {
    await _database.collection('tasks').doc(taskId).delete();
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }


}


