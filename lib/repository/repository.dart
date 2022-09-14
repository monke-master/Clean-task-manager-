abstract class Repository {

  // User methods
  Future<int> addUser(Map<String, dynamic> userData);

  // Future<Map<String, dynamic>> getUser(String userId);
  //
  // Future<Map<String, dynamic>> getUserByEmail(String email);
  //
  // Future<int> updateUser(Map<String, dynamic> userData);
  //
  // Future<int> deleteUser(String userId);
  //
  // // Category methods
  // Future<int> addCategory(Map<String, dynamic> categoryData);
  //
  // Future<Map<String, dynamic>> getCategory(String categoryId);
  //
  // List<Map<String, dynamic>> getCategoriesList(String categoryId);
  //
  // Future<int> updateCategory(Map<String, dynamic> categoryData);
  //
  // Future<int> deleteCategory(String categoryId);
  //
  // // Task methods
  // Future<int> addTask(Map<String, dynamic> categoryData);
  //
  // Future<Map<String, dynamic>> getTask(String taskId);
  //
  // Future<List<Map<String, dynamic>>> getUserTasks(String userId);
  //
  // Future<List<Map<String, dynamic>>> getCategoryTasks(String categoryId);
  //
  // Future<int> updateTask(Map<String, dynamic> taskData);
  //
  // Future<int> deleteTask(String taskId);
}
