
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:task_manager_arch/models/category.dart';
import 'package:task_manager_arch/models/data_response.dart';
import 'package:task_manager_arch/models/user.dart';
import 'package:task_manager_arch/repository/api.dart';
import 'package:task_manager_arch/repository/in_memory_cache.dart';
import 'package:task_manager_arch/repository/local_database.dart';

import '../models/task.dart';

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
      await _localRepo.putConfig({
        'user_id': 'guest',
        'theme': 'system',
        'language': Platform.localeName,
        'notify_about_sign_up': true
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
    if (getUser.statusCode == 200) {
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
  }

  // Аутентификация
  Future<DataResponse> authenticate(User user) async {
    DataResponse webResponse = await _apiRepo.getUserByEmail(user.email!);

    if (webResponse.statusCode == 200) {
      if (webResponse.data['password'] == user.password) {
        return DataResponse(data: {"body": "Success"} , statusCode: 200);
      } else {
        return DataResponse(
            data: {"body": "Invalid login data"} ,
            statusCode: 401);
      }
    }
    return webResponse;
  }

  // Создание учетной записи
  Future<DataResponse> signUp(User user) async {
    String userId = user.id;
    // Каст модели в Json
    Map<String, dynamic> userJson = {
      "email": user.email,
      "password": user.password,
      "registration_date": user.registrationDate.toString()
    };
    // Создание учетной записи на сервере
    DataResponse createUser = await _apiRepo.addUser(userId, userJson);
    if (createUser.statusCode == 200) {
      // Добавляем пользователя в кэш и на устройство
      _cacheRepo.addUser(userId, userJson);
     await _localRepo.putUser(userId, userJson);

      // Редактируем конфигурацию
      DataResponse config = await _localRepo.getConfig();
      config.data['user_id'] = userId;
      await _localRepo.putConfig(config.data);

      // Редактируем id создателя категории
      Map<String, dynamic> categories = _cacheRepo.getCategoriesList();
      for (String categoryId in categories.keys) {
        Map<String, dynamic> category = categories[categoryId];
        category['user_id'] = userId;
        _cacheRepo.updateCategory(categoryId, category);
        await _localRepo.putCategory(categoryId, category);
      }

      // Редактируем id создателя задачи
      Map<String, dynamic> tasks = _cacheRepo.getUserTasks();
      for (String taskId in tasks.keys) {
        Map<String, dynamic> task = tasks[taskId];
        task['user_id'] = userId;
        _cacheRepo.updateTask(taskId, task);
        await _localRepo.putTask(taskId, task);
      }

      // Загружаем данные с устройства на сервер
      DataResponse syncResponse = await syncFromLocalToServer();
      return syncResponse;
    } else {
      return createUser;
    }
  }

  // Загрузка данных с устройства на сервер
  Future<DataResponse> syncFromLocalToServer() async {
    Map<String, dynamic> categories = _cacheRepo.getCategoriesList();
    Map<String, dynamic> tasks = _cacheRepo.getUserTasks();

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

  // Получение пользователя
  User getUser() {
    Map<String, dynamic> userJson = _cacheRepo.getUser();
    User user = User(
        id: userJson['id'],
        email: userJson.containsKey("email") ? userJson['email'] : null,
        password: userJson.containsKey("password") ? userJson['password'] : null,
        registrationDate: userJson.containsKey("registration_date") ?
                          DateTime.parse(userJson['registration_date']) : null);
    return user;
  }

  // Редактирование данных пользователя
  Future<DataResponse> updateUser(User oldUser, User newUser) async {
    // Каст в Json
    Map<String, dynamic> newUserJson = {
      'email': newUser.email,
      'password': newUser.password,
    };

    DataResponse authResponse = await authenticate(oldUser);
    if (authResponse.statusCode == 200) {
      _cacheRepo.updateUser(newUserJson);
      _localRepo.putUser(oldUser.id, newUserJson);
      DataResponse apiResponse = await _apiRepo.updateUser(
          newUser.id,
          newUserJson);
      return apiResponse;
    } else {
      return authResponse;
    }
  }

  // Удаление пользователя
  Future<DataResponse> deleteUser(User user) async {
    String userId = _cacheRepo.getUser()['id'];
    // Удаление данных с сервера (при наличии учетной записи)
    if (_sync) {
      DataResponse authResponse = await authenticate(user);
      if (authResponse.statusCode == 200) {
        _deleteUserLocally(userId);
        return await _apiRepo.deleteUser(userId);
      }
      return authResponse;
    } else {
      _deleteUserLocally(userId);
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }
  }

  // Удаление пользователя из кэша и памяти устройства
  Future<void> _deleteUserLocally(String userId) async {
    _cacheRepo.deleteUser();
    await _localRepo.putConfig({"user_id": "guest"});
    await _localRepo.deleteUser(userId);
  }

  // Методы для работы с категориями
  // Получение категории
  Category getCategory(String categoryId) {
    Map<String, dynamic>  categoryJson = _cacheRepo.getCategory(categoryId);
    Category category = Category(
        categoryId: categoryId,
        userId: categoryJson['userId'],
        title: categoryJson['title'],
        creationDate: categoryJson['creation_date']);
    return category;
  }

  // Получение списка категорий
  List<Category> getCategoriesList() {
    Map<String, dynamic>  categoriesJson = _cacheRepo.getCategoriesList();
    List<Category> categories = [];
    for (String categoryId in categoriesJson.keys) {
      Map<String, dynamic>  categoryJson = categoriesJson[categoryId];
      Category category = Category(
          categoryId: categoryId,
          userId: categoryJson['userId'],
          title: categoryJson['title'],
          creationDate: categoryJson['creation_date']);
      categories.add(category);
    }
    return categories;
  }

  // Добавление категории
  Future<DataResponse> addCategory(User user, Category category) async {
    Map<String, dynamic>  categoryJson = {
      'user_id': category.userId,
      'title': category.title,
      'creation_date': category.creationDate,
    };

    if (_sync) {
      DataResponse authResponse = await authenticate(user);
      if (authResponse.statusCode == 200) {
        _addCategoryLocally(category.categoryId, categoryJson);
        return await _apiRepo.addCategory(category.categoryId, categoryJson);
      }
      return authResponse;
    } else {
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }
  }

  // Добавление категории в кэш и память устройства
  Future<void> _addCategoryLocally(String categoryId, Map<String, dynamic>categoryJson) async {
    _cacheRepo.addCategory(categoryId, categoryJson);
    await _localRepo.putCategory(categoryId, categoryJson);
  }

  // Редактирование категории
  Future<DataResponse> updateCategory(User user, Category newCategory) async {
     Map<String, dynamic> newCategoryJson = {
       'title': newCategory.title
     };

     if (_sync) {
       DataResponse authResponse = await authenticate(user);
       if (authResponse.statusCode == 200) {
         _updateCategoryLocally(newCategory.categoryId, newCategoryJson);
         return await _apiRepo.updateCategory(
             newCategory.categoryId,
             newCategoryJson);
       }
       return authResponse;
     } else {
       _updateCategoryLocally(newCategory.categoryId, newCategoryJson);
       return DataResponse(data: {"body": "Success"}, statusCode: 200);
     }

  }

  // Редактирование категории в кэше и памяти устройства
  Future<void> _updateCategoryLocally(String categoryId,
                                      Map<String, dynamic> categoryJson) async {
     _cacheRepo.updateCategory(categoryId, categoryJson);
     await _localRepo.putCategory(categoryId, categoryJson);

  }

   // Удаление категории
  Future<DataResponse> deleteCategory(User user, String categoryId) async {
     if (_sync) {
       DataResponse authResponse = await authenticate(user);
       if (authResponse.statusCode == 200) {
         _deleteCategoryLocally(categoryId);
         return await _apiRepo.deleteCategory(categoryId);
       }
       return authResponse;
     } else {
       _deleteCategoryLocally(categoryId);
       return DataResponse(data: {"body": "Success"}, statusCode: 200);
     }
  }

  // Удаление категории из кэша и памяти устройства
  Future<void> _deleteCategoryLocally(String categoryId) async {
    _cacheRepo.deleteCategory(categoryId);
    await _localRepo.deleteCategory(categoryId);
  }


  // Методы для работы с задачами
  // Получение задачи
  Task getTask(String taskId) {
     Map<String, dynamic> taskJson = _cacheRepo.getTask(taskId);
     Task task = Task(
         taskId: taskId,
         userId: taskJson['user_id'],
         categoryId: taskJson['category_id'],
         title: taskJson['title'],
         date: taskJson['date'],
         creationDate: taskJson['creation_date'],
         completed: taskJson['completed'],
         emailed: taskJson['emailed'],
         repeating: taskJson['repeating']);
     return task;
  }

  // Добавление задачи
  Future<DataResponse> addTask(User user, Task task) async {
    Map<String, dynamic> taskJson = {
      'user_id': task.userId,
      'category_id': task.categoryId,
      'title': task.title,
      'date': task.date,
      'completed': task.completed,
      'emailed': task.emailed,
      'creation_date': task.creationDate,
      'repeating': task.repeating
    };

    if (_sync) {
      DataResponse authResponse = await authenticate(user);
      if (authResponse.statusCode == 200) {
        _addTaskLocally(task.taskId, taskJson);
        return await _apiRepo.addTask(task.taskId, taskJson);
      }
      return authResponse;
    } else {
      _addTaskLocally(task.taskId, taskJson);
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }
  }

  // Добавление задачи в кэш и память устройства
  Future<void> _addTaskLocally(String taskId, Map<String, dynamic> taskJson) async {
    _cacheRepo.addTask(taskId, taskJson);
    _localRepo.putTask(taskId, taskJson);
  }

  // Получение всех задач указанной категории
  List<Task> getCategoryTasks(String categoryId) {
    Map<String, dynamic> tasksJson = _cacheRepo.getCategoryTasks(categoryId);
    List<Task> tasks = [];
    for (String taskId in tasksJson.keys) {
      Map<String, dynamic> taskJson = tasksJson[taskId];
      Task task = Task(
          taskId: taskId,
          userId: taskJson['user_id'],
          categoryId: taskJson['category_id'],
          title: taskJson['title'],
          date: taskJson['date'],
          creationDate: taskJson['creation_date'],
          completed: taskJson['completed'],
          emailed: taskJson['emailed'],
          repeating: taskJson['repeating']);
      tasks.add(task);
    }
    return tasks;
  }

  // Получение всех пользовательских задач
  List<Task> getUserTasks() {
    Map<String, dynamic> tasksJson = _cacheRepo.getUserTasks();
    List<Task> tasks = [];
    for (String taskId in tasksJson.keys) {
      Map<String, dynamic> taskJson = tasksJson[taskId];
      Task task = Task(
          taskId: taskId,
          userId: taskJson['user_id'],
          categoryId: taskJson['category_id'],
          title: taskJson['title'],
          date: taskJson['date'],
          creationDate: taskJson['creation_date'],
          completed: taskJson['completed'],
          emailed: taskJson['emailed'],
          repeating: taskJson['repeating']);
      tasks.add(task);
    }
    return tasks;
  }

  // Редактирование задачи
  Future<DataResponse> updateTask(User user, Task newTask) async {
    Map<String, dynamic> newTaskJson = {
      'category_id': newTask.categoryId,
      'title': newTask.title,
      'date': newTask.date,
      'completed': newTask.completed,
      'emailed': newTask.emailed,
      'repeating': newTask.repeating
    };

    if (_sync) {
      DataResponse authResponse = await authenticate(user);
      if (authResponse.statusCode == 200) {
        _updateTaskLocally(newTask.taskId, newTaskJson);
        return await _apiRepo.updateTask(newTask.taskId, newTaskJson);
      }
      return authResponse;
    } else {
      _updateTaskLocally(newTask.taskId, newTaskJson);
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }

  }

  // Редактирование задачи в кэше и памяти устройства
  Future<void> _updateTaskLocally(String taskId, Map<String, dynamic> taskJson) async {
    _cacheRepo.updateTask(taskId, taskJson);
    await _localRepo.putTask(taskId, taskJson);
  }

  // Удаление задачи
  Future<DataResponse> deleteTask(User user, String taskId) async {
    if (_sync) {
      DataResponse authResponse = await authenticate(user);
      if (authResponse.statusCode == 200) {
        _deleteTaskLocally(taskId);
        return await _apiRepo.deleteTask(taskId);
      }
      return authResponse;
    }
    else {
      _deleteTaskLocally(taskId);
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }
  }

  // Удаление задачи из кэша и памяти устройства
  Future<void> _deleteTaskLocally(String taskId) async {
    _cacheRepo.deleteTask(taskId);
    await _localRepo.deleteTask(taskId);
  }

}