// Класс для хранения данных в кэше
class InMemoryCache {

  final Map<String, dynamic> _user = {};
  final Map<String, Map<String, dynamic>> _categories = {};
  final Map<String, Map<String, dynamic>> _tasks = {};

  // User methods
  void addUser(String userId, Map<String, dynamic> userData) {
    _user.addAll(userData);
    _user['id'] = userId;
  }

  Map<String, dynamic> getUser() {
    return _user;
  }

  void updateUser(Map<String, dynamic> userData) {
    _user['email'] = userData['email'];
    _user['password'] = userData['password'];
  }

  void deleteUser() {
    _user.clear();
  }

  // Category methods
  void addCategory(String categoryId, Map<String, dynamic> categoryData) {
    _categories[categoryId] = categoryData;

  }

  Map<String, dynamic>? getCategory(String categoryId) {
    if (_categories.containsKey(categoryId)) {
      Map<String, dynamic> category = {};
      category.addAll(_categories[categoryId]!);
      category["category_id"] = categoryId;
      return category;
    }
    return null;
  }

  Map<String, dynamic> getCategoriesList() {
    return _categories;
  }

  void updateCategory(String categoryId, Map<String, dynamic> categoryData) {
    for (String key in categoryData.keys) {
      _categories[categoryId]![key] = categoryData[key];
    }
  }

  void deleteCategory(String categoryId) {
    _categories.remove(categoryId);
  }

  // Task methods
  void addTask(String taskId, Map<String, dynamic> taskData) {
    _tasks[taskId] = taskData;
  }

  Map<String, dynamic>? getTask(String taskId) {
    if (_tasks.containsKey(taskId)) {
      Map<String, dynamic> task = {};
      task.addAll(_tasks[taskId]!);
      task['task_id'] = taskId;
      return _tasks[taskId]!;
    }
    return null;
  }

  Map<String, dynamic> getUserTasks() {
    return _tasks;
  }

  Map<String, dynamic> getCategoryTasks(String categoryId) {
    Map<String, dynamic> responseData = {};
    for (String taskId in _tasks.keys) {
      if (_tasks[taskId]!['categoryId'] == categoryId) {
        responseData[taskId] = _tasks[taskId];
      }
    }
    return responseData;
  }

  void updateTask(String taskId, Map<String, dynamic> taskData) {
    for (String key in taskData.keys) {
      _tasks[taskId]![key] = taskData[key];
    }
  }

  void deleteTask(String taskId) {
    _tasks.remove(taskId);
  }

}