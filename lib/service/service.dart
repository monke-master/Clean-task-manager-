import 'package:task_manager_arch/models/category.dart';
import 'package:task_manager_arch/models/configuration.dart';
import 'package:task_manager_arch/models/data_response.dart';
import 'package:task_manager_arch/models/user.dart';
import 'package:task_manager_arch/repository/api.dart';
import 'package:task_manager_arch/repository/in_memory_cache.dart';
import 'package:task_manager_arch/repository/local_database.dart';

import '../models/task.dart';

class Service {

  final InMemoryCache _cacheRepo;
  final Api _apiRepo;
  final LocalDatabase _localRepo;

  Service(this._cacheRepo, this._apiRepo, this._localRepo);

  // Копирование данных из локального хранилища в кэш
  Future<void> syncFromLocalToCache(String userId) async {
    DataResponse getUser = await _localRepo.getUser(userId);
    if (getUser.statusCode == 200) {
      _cacheRepo.addUser(userId, getUser.data);

      Map<String, dynamic> getCategories = await _localRepo.getCategoriesList(userId);
      for (String categoryId in getCategories.keys) {
        _cacheRepo.addCategory(categoryId, getCategories[categoryId]);
      }

      Map<String, dynamic> getTasks = await _localRepo.getUserTasks(userId);
      for (String taskId in getTasks.keys) {
        _cacheRepo.addTask(taskId, getTasks[taskId]);
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
      Map<String, dynamic> config = (await _localRepo.getConfig())!;
      config['user_id'] = userId;
      await _localRepo.putConfig(config);

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

  // Проверка необходимости синхронизации
  Future<void> checkForSync() async {
    Map<String, dynamic>? errorsList = await _localRepo.getErrorsList();
    if (errorsList.isEmpty) {
      return;
    }

    for (String errorId in errorsList.keys) {
      Map<String, dynamic> error = errorsList[errorId];
      switch (error['type']) {
        case 'put':
          switch (error['collection']) {
            case 'categories':
              Map<String, dynamic> categoryData = error['data'];
              DataResponse apiResponse = await _apiRepo.addCategory(
                  categoryData['category_id'], categoryData);
              if (apiResponse.statusCode != 200) {
                return;
              }
              await _localRepo.deleteError(errorId);
              break;
            case 'tasks':
              Map<String, dynamic> taskData = error['data'];
              DataResponse apiResponse = await _apiRepo.addTask(
                  taskData['task_id'], taskData);
              if (apiResponse.statusCode != 200) {
                return;
              }
              await _localRepo.deleteError(errorId);
              break;
          }
          break;
        case 'post':
          switch (error['collection']) {
            case 'categories':
              Map<String, dynamic> categoryData = error['data'];
              DataResponse apiResponse = await _apiRepo.updateCategory(
                  categoryData['category_id'], categoryData);
              if (apiResponse.statusCode != 200) {
                return;
              }
              await _localRepo.deleteError(errorId);
              break;
            case 'tasks':
              Map<String, dynamic> taskData = error['data'];
              DataResponse apiResponse = await _apiRepo.updateTask(
                  taskData['task_id'], taskData);
              if (apiResponse.statusCode != 200) {
                return;
              }
              await _localRepo.deleteError(errorId);
              break;
          }
          break;
        case 'delete':
          switch (error['collection']) {
            case 'categories':
              Map<String, dynamic> categoryData = error['data'];
              DataResponse apiResponse =
                await _apiRepo.deleteCategory(categoryData['category_id']);
              if (apiResponse.statusCode != 200) {
                return;
              }
              await _localRepo.deleteError(errorId);
              break;
            case 'tasks':
              Map<String, dynamic> taskData = error['data'];
              DataResponse apiResponse =
                await _apiRepo.deleteTask(taskData['task_id']);
              if (apiResponse.statusCode != 200) {
                return;
              }
              await _localRepo.deleteError(errorId);
              break;
          }
      }
    }
  }

  // Загрузка всех данных с устройства на сервер
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

  // Получение пользователя из локального хранилища
  Future<User?> getUserFromLocal(String userId) async {
    DataResponse ldbResponse = await _localRepo.getUser(userId);
    if (ldbResponse.statusCode == 404) {
      return null;
    }
    Map<String, dynamic> userJson = ldbResponse.data;
    User user = User(
        id: userJson['id'],
        email: userJson['email'],
        password: userJson['password'],
        registrationDate: userJson['registrationDate']);
    return user;
  }

  // Редактирование данных пользователя
  Future<DataResponse> updateUser(User newUser) async {
    // Каст в Json
    Map<String, dynamic> newUserJson = {
      'email': newUser.email,
      'password': newUser.password,
    };

    // Вносим локальные изменения только при успешном ответе сервера
    DataResponse apiResponse = await _apiRepo.updateUser(
        newUser.id,
        newUserJson);
    if (apiResponse.statusCode == 200) {
      _cacheRepo.updateUser(newUserJson);
      _localRepo.putUser(newUser.id, newUserJson);
    }

    return apiResponse;
  }

  // Удаление пользователя
  Future<DataResponse> deleteUser(bool sync) async {
    String userId = _cacheRepo.getUser()['id'];
    // Удаление данных с сервера (при наличии учетной записи)
    if (sync) {
      DataResponse apiResponse = await _apiRepo.deleteUser(userId);
      // Вносим локальные изменения только при успешном ответе сервера
      if (apiResponse.statusCode == 200) {
        _deleteUserLocally(userId);
      }
      return apiResponse;
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
  Category? getCategory(String categoryId) {
    Map<String, dynamic>?  categoryJson = _cacheRepo.getCategory(categoryId);
    if (categoryJson != null) {
      Category category = Category(
          categoryId: categoryId,
          userId: categoryJson['user_id'],
          title: categoryJson['title'],
          creationDate: DateTime.parse(categoryJson['creation_date']));
      return category;
    }
    return null;
  }

  // Получение списка категорий
  List<Category> getCategoriesList() {
    Map<String, dynamic>  categoriesJson = _cacheRepo.getCategoriesList();
    List<Category> categories = [];
    for (String categoryId in categoriesJson.keys) {
      Map<String, dynamic>  categoryJson = categoriesJson[categoryId];
      Category category = Category(
          categoryId: categoryId,
          userId: categoryJson['user_id'],
          title: categoryJson['title'],
          creationDate: DateTime.parse(categoryJson['creation_date']));
      categories.add(category);
    }
    return categories;
  }

  // Добавление категории
  Future<DataResponse> addCategory(Category category, bool sync) async {
    Map<String, dynamic>  categoryJson = {
      'user_id': category.userId,
      'title': category.title,
      'creation_date': category.creationDate.toString(),
    };

    _addCategoryLocally(category.categoryId, categoryJson);
    if (sync) {
      return await _apiRepo.addCategory(category.categoryId, categoryJson);
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
  Future<DataResponse> updateCategory(Category newCategory, bool sync) async {
     Map<String, dynamic> newCategoryJson = {
       'title': newCategory.title
     };

    _updateCategoryLocally(newCategory.categoryId, newCategoryJson);
     if (sync) {
       return await _apiRepo.updateCategory(
           newCategory.categoryId,
           newCategoryJson);
     } else {
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
  Future<DataResponse> deleteCategory(String categoryId, bool sync) async {
    _deleteCategoryLocally(categoryId);
     if (sync) {
       return await _apiRepo.deleteCategory(categoryId);
     } else {
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
  Task? getTask(String taskId) {
     Map<String, dynamic>? taskJson = _cacheRepo.getTask(taskId);
     if (taskJson != null) {
      Task task = Task(
          taskId: taskId,
          userId: taskJson['user_id'],
          categoryId: taskJson['category_id'],
          title: taskJson['title'],
          date: DateTime.parse(taskJson['date']),
          creationDate: DateTime.parse(taskJson['creation_date']),
          completed: int.parse(taskJson['completed']) == 1 ? true : false,
          emailed: taskJson['emailed'] != null
              ? (int.parse(taskJson['emailed']) == 1 ? true : false)
              : null,
          repeating: int.parse(taskJson['repeating']));
      return task;
    }
     return null;
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

  // Добавление задачи
  Future<DataResponse> addTask(Task task, bool sync) async {
    User user = getUser();
    Map<String, dynamic> taskJson = {
      'user_id': task.userId,
      'category_id': task.categoryId,
      'title': task.title,
      'date': task.date.toString(),
      'completed': task.completed ? 1 : 0,
      'emailed': task.emailed != null ? (task.emailed! ? 1 : 0) : null,
      'creation_date': task.creationDate.toString(),
      'repeating': task.repeating.toString()
    };

    _addTaskLocally(task.taskId, taskJson);
    if (sync) {
      return await _apiRepo.addTask(task.taskId, taskJson);
    } else {
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }
  }

  // Добавление задачи в кэш и память устройства
  Future<void> _addTaskLocally(String taskId, Map<String, dynamic> taskJson) async {
    _cacheRepo.addTask(taskId, taskJson);
    _localRepo.putTask(taskId, taskJson);
  }

  // Редактирование задачи
  Future<DataResponse> updateTask(Task newTask, bool sync) async {
    Map<String, dynamic> newTaskJson = {
      'category_id': newTask.categoryId,
      'title': newTask.title,
      'date': newTask.date,
      'completed': newTask.completed,
      'emailed': newTask.emailed,
      'repeating': newTask.repeating
    };

    _updateTaskLocally(newTask.taskId, newTaskJson);
    if (sync) {
      return await _apiRepo.updateTask(newTask.taskId, newTaskJson);
    } else {
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }

  }

  // Редактирование задачи в кэше и памяти устройства
  Future<void> _updateTaskLocally(String taskId, Map<String, dynamic> taskJson) async {
    _cacheRepo.updateTask(taskId, taskJson);
    await _localRepo.putTask(taskId, taskJson);
  }

  // Удаление задачи
  Future<DataResponse> deleteTask(String taskId, bool sync) async {
    _deleteTaskLocally(taskId);
    if (sync) {
      return await _apiRepo.deleteTask(taskId);
    }
    else {
      return DataResponse(data: {"body": "Success"}, statusCode: 200);
    }
  }

  // Удаление задачи из кэша и памяти устройства
  Future<void> _deleteTaskLocally(String taskId) async {
    _cacheRepo.deleteTask(taskId);
    await _localRepo.deleteTask(taskId);
  }

  // Методы для работы с конфигурацией
  // Получение конфигурации
  Future<Configuration?> getConfiguration() async {
    Map<String, dynamic>? ldbResponse = await _localRepo.getConfig();
    if (ldbResponse == null) {
      return null;
    }
    Configuration configuration = Configuration(
        userId: ldbResponse['user_id'],
        language: ldbResponse['language'],
        theme: ldbResponse['theme'],
        notifyAboutSignUp: ldbResponse['notify_about_sign_up']);
    return configuration;
  }

  // Установка конфигурации
  Future<void> setConfiguration(Configuration configuration) async {
    Map<String, dynamic> configJson = {
      "user_id": configuration.userId,
      "theme": configuration.theme,
      "language": configuration.language,
      "notify_about_sign_up": configuration.notifyAboutSignUp
    };
    await _localRepo.putConfig(configJson);
  }

}