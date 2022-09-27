import 'dart:developer';

import 'package:http/http.dart';
import 'package:task_manager_arch/models/data_response.dart';
import 'package:task_manager_arch/repository/api.dart';
import 'package:task_manager_arch/repository/in_memory_cache.dart';
import 'package:task_manager_arch/repository/local_database.dart';

class Service {

  bool _sync = false;

  InMemoryCache _cacheRepo;
  Api _apiRepo;
  LocalDatabase _localRepo;

  Service(this._cacheRepo, this._apiRepo, this._localRepo);

  Future<void> initialize() async {
    // Проверка наличия активного пользователя на устройстве
    DataResponse config = await _localRepo.getConfig();
    String userId;
    if (config.statusCode == 404) {
      _localRepo.putConfig({
        'user_id': 'guest',
        'theme': 'system'
      });
      userId = "guest";
      _cacheRepo.addUser(userId, {});
      await _localRepo.putUser(userId, {});
      _sync = false;

    } else {
      userId = config.data['user_id'];
      _sync = userId != 'guest';
    }
    // Копирование данных из локального хранилища в кэш
    DataResponse getCategories = await _localRepo.getCategoriesList(userId);
    if (getCategories.statusCode == 200) {
      for (String categoryId in getCategories.data.keys) {
        _cacheRepo.addCategory(categoryId, getCategories.data[categoryId]);
      }
    }

    DataResponse getTasks = await _localRepo.getUserTasks(userId);
    if (getTasks.statusCode == 200) {
      for (String taskId in getTasks.data.keys) {
        _cacheRepo.addTask(taskId, getTasks.data[taskId]);
      }
    }

  }

  Future<DataResponse> authenticate(String userId) async {
    var localResponse = await _localRepo.getUser(userId);
    var webResponse = await _apiRepo.getUser(userId);
    if (webResponse.statusCode == 200 && localResponse.statusCode == 200) {
      if (webResponse.data == localResponse.data) {
        return DataResponse(data: {"body": "Success"} , statusCode: 200);
      } else {
        return DataResponse(data: {"body": "Invalid login data"} , statusCode: 401);
      }
    }
    return webResponse;
  }






}