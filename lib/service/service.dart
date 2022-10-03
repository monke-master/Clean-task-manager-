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

  final InMemoryCache _cacheRepo;
  final Api _apiRepo;
  final LocalDatabase _localRepo;

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
    String userId = user.id;
    // Каст модели в Json
    var userJson = {
      "email": user.email,
      "password": user.password,
      "registration_date": user.registrationDate.toString()
    };
    // Создание учетной записи на сервере
    var createUser = await _apiRepo.addUser(userId, userJson);
    if (createUser.statusCode == 200) {
      // Добавляем пользователя в кэш и на устройство
      _cacheRepo.addUser(userId, userJson);
      await _localRepo.putUser(userId, userJson);

      // Редактируем конфигурацию
      var config = await _localRepo.getConfig();
      config.data['user_id'] = userId;
      await _localRepo.putConfig(config.data);

      // Редактируем id создателя категории
      var categories = _cacheRepo.getCategoriesList().data;
      for (String categoryId in categories.keys) {
        var category = categories[categoryId];
        category['user_id'] = userId;
        _cacheRepo.updateCategory(categoryId, category);
        await _localRepo.putCategory(categoryId, category);
      }

      // Редактируем id создателя задачи
      var tasks = _cacheRepo.getUserTasks().data;
      for (String taskId in tasks.keys) {
        var task = tasks[taskId];
        task['user_id'] = userId;
        _cacheRepo.updateTask(taskId, task);
        await _localRepo.putTask(taskId, task);
      }

      // Загружаем данные с устройства на сервер
      var syncResponse = await syncFromLocalToServer();
      return syncResponse;
    } else {
      return createUser;
    }
  }

  // Загрузка данных с устройства на сервер
  Future<DataResponse> syncFromLocalToServer() async {
    var categories = _cacheRepo.getCategoriesList().data;
    var tasks = _cacheRepo.getUserTasks().data;

    // Загрузка категорий
    for (String categoryId in categories.keys) {
      DataResponse webResponse = await _apiRepo.addCategory(
          categoryId,
          categories[categoryId]);
      if (webResponse.statusCode != 200) {
        return webResponse;
      }
    }

    // Загрузка задач
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

  // Редактирование данных пользователя
  Future<DataResponse> updateUser(User oldUser, User newUser) async {
    // Каст в Json
    var newUserJson = {
      'email': newUser.email,
      'password': newUser.password,
    };

    // Редактирование данных в кэше и на устройстве
    _cacheRepo.updateUser(newUserJson);
    _localRepo.putUser(newUser.id, newUserJson);

    // Редактирование данных на сервере
    if (_sync) {
      var authResponse = await authenticate(oldUser);
      if (authResponse.statusCode == 200) {
        var apiResponse = await _apiRepo.updateUser(newUser.id, newUserJson);
        return apiResponse;
      } else {
        return authResponse;
      }
    } else {
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }
  }

  // Получение пользователя
  User getUser() {
    var userJson = _cacheRepo.getUser();
    User user = User(
        id: userJson.data['id'],
        email: userJson.data['email'],
        password: userJson.data['password'],
        registrationDate: userJson.data['registrationDate']);
    return user;
  }

  // Удаление пользователя
  Future<DataResponse> deleteUser() async {
    String userId = _cacheRepo.getUser().data['id'];
    var tasksJsonList = _cacheRepo.getUserTasks().data;
    var categoriesJsonList = _cacheRepo.getCategoriesList().data;

    // Удаление задач из кэша и памяти устройства
    for (String taskId in tasksJsonList.keys) {
      _cacheRepo.deleteTask(taskId);
      _localRepo.deleteTask(taskId);
    }

    // Удаление категорий из кэша и памяти устройства
    for (String categoryId in categoriesJsonList.keys) {
      _cacheRepo.deleteCategory(categoryId);
      _localRepo.deleteCategory(categoryId);
    }

    // Удаление пользователя из кэша и памяти устройства
    _cacheRepo.deleteUser();
    await _localRepo.putConfig({"user_id": "guest"});
    await _localRepo.deleteUser(userId);

    // Удаление данных с сервера (при наличии учетной записи)
    if (_sync) {
      // Удаление задач
      for (String taskId in tasksJsonList.keys) {
        DataResponse deleteResponse = await _apiRepo.deleteTask(taskId);
        if (deleteResponse.statusCode != 200) {
          return deleteResponse;
        }
      }
      // Удаление категорий
      for (String categoryId in categoriesJsonList.keys) {
        DataResponse deleteResponse = await _apiRepo.deleteCategory(categoryId);
        if (deleteResponse.statusCode != 200) {
          return deleteResponse;
        }
      }
      // Удаление пользователя
      return await _apiRepo.deleteUser(userId);
    }

    return DataResponse(data: {"body": "Success"}, statusCode: 200);
  }


}