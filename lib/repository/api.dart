import 'package:task_manager_arch/repository/repository.dart';
import 'package:http/http.dart' as http;

class Api extends Repository {

  final String _base ='http://localhost:8080/';

  // User methods
  @override
  Future<int> addUser(Map<String, dynamic> userData) async {
    final String userId = userData['id'];
    var uri = Uri.parse("${_base}user/$userId");
    try {
      var response = await http.post(uri, body: {
        "email": userData['email'],
        "password": userData['password'],
        "registration_date": userData['registration_date']
      });
      return response.statusCode;
    } catch (error) {
      print(error);
      return 0;
    }
  }

  // Map<String, dynamic> getUser(String userId) {
  //
  // }
  //
  // Map<String, dynamic> getUserByEmail(String email);
  //
  // void updateUser(Map<String, dynamic> userData);
  //
  // void deleteUser(String userId);
  //
  // // Category methods
  // void addCategory(Map<String, dynamic> categoryData);
  //
  // Map<String, dynamic> getCategory(String categoryId);
  //
  // List<Map<String, dynamic>> getCategoriesList(String categoryId);
  //
  // void updateCategory(Map<String, dynamic> categoryData);
  //
  // void deleteCategory(String categoryId);
  //
  // // Task methods
  // void addTask(Map<String, dynamic> categoryData);
  //
  // Map<String, dynamic> getTask(String taskId);
  //
  // List<Map<String, dynamic>> getUserTasks(String userId);
  //
  // List<Map<String, dynamic>> getCategoryTasks(String categoryId);
  //
  // void updateTask(Map<String, dynamic> taskData);
  //
  // void deleteTask(String taskId);
}