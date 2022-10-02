import 'dart:developer';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:task_manager_arch/models/data_response.dart';
import 'package:task_manager_arch/models/user.dart';
import 'package:task_manager_arch/repository/api.dart';
import 'package:task_manager_arch/repository/in_memory_cache.dart';
import 'package:task_manager_arch/repository/local_database.dart';

class Service {

  bool _sync = false;

  InMemoryCache _cacheRepo;
  Api _apiRepo;
  LocalDatabase _localRepo;

  Service(this._cacheRepo, this._apiRepo, this._localRepo);

  // Инициализация сервиса
  Future<void> initialize() async {
    // Проверка наличия активного пользователя на устройстве
    DataResponse config = await _localRepo.getConfig();
    String userId;
    // Если на устройстве нет авторизированного пользователя,
    if (config.statusCode == 404) { // то создаем гостевую учетную запись
      _localRepo.putConfig({
        'user_id': 'guest',
        'theme': 'system'
      });
      userId = "guest";
      await _localRepo.putUser(userId, {});
      _sync = false;
    } else { // иначе получаем данные для входа
      userId = config.data['user_id'];
      _sync = userId != 'guest';
    }
    // Копирование данных из локального хранилища в кэш
    DataResponse getUser = await _localRepo.getUser(userId);
    _cacheRepo.addUser(userId, getUser.data);

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

  // Аутентификация
  Future<DataResponse> authenticate(User user) async {
    var webResponse = await _apiRepo.getUserByEmail(user.email);

    if (webResponse.statusCode == 200) {
      if (webResponse.data['password'] == user.password) {
        return DataResponse(data: {"body": "Success"} , statusCode: 200);
      } else {
        return DataResponse(data: {"body": "Invalid login data"} , statusCode: 401);
      }
    }
    return webResponse;
  }

  // Создание учетной записи
  Future<DataResponse> signUp(User user) async {
    // Каст модели в Json
    var jsonUser = {
      "email": user.email,
      "password": user.password,
      "registration_date": user.registrationDate.toString()
    };
    // Получение id
    String id = user.id;
    // СОздание учетной записи на сервере
    var createUser = await _apiRepo.addUser(id, jsonUser);
    // В случае успешного добавления
    if (createUser.statusCode == 200) {
      // Добавляем пользователя в кэш и на устройство
      _cacheRepo.addUser(id, jsonUser);
      await _localRepo.putUser(id, jsonUser);
      // Редактируем конфигурацию
      var config = await _localRepo.getConfig();
      config.data['user_id'] = id;
      await _localRepo.putConfig(config.data);
      // Редактируем категории
      var categories = _cacheRepo.getCategoriesList().data;
      for (String categoryId in categories.keys) {
        var category = categories[categoryId];
        category['user_id'] = id;
        _cacheRepo.updateCategory(categoryId, category);
        await _localRepo.putCategory(categoryId, category);
      }
      // Редактируем задачи
      var tasks = _cacheRepo.getUserTasks().data;
      for (String taskId in tasks.keys) {
        var task = tasks[taskId];
        task['user_id'] = id;
        _cacheRepo.updateTask(taskId, task);
        await _localRepo.putTask(taskId, task);
      }
      // Загружаем данные с устройства на сервер
      await syncFromLocalToServer();
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    } else {
      return createUser;
    }
  }

  // Загрузка данных с устройства на сервер
  Future<DataResponse> syncFromLocalToServer() async {
    var categories = _cacheRepo.getCategoriesList().data;
    var tasks = _cacheRepo.getUserTasks().data;

    for (String categoryId in categories.keys) {
      DataResponse webResponse = await _apiRepo.addCategory(
          categoryId,
          categories[categoryId]);
      if (webResponse.statusCode != 200) {
        return webResponse;
      }
    }
    for (String taskId in tasks.keys) {
      DataResponse webResponse = await _apiRepo.addTask(
          taskId,
          tasks[taskId]);
      if (webResponse.statusCode != 200) {
        return webResponse;
      }
    }
    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }







}