import 'package:localstore/localstore.dart';
import 'package:task_manager_arch/repository/repository_response.dart';

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

  // User methods
  RepositoryResponse putUser(String userId, Map<String, dynamic> data) {
    _database.collection('user').doc(userId).set(data);
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  Future<RepositoryResponse> getUser(String userId) async {
    var result = await _database.collection('user').doc(userId).get();
    if (result != null) {
      return RepositoryResponse(data: result, statusCode: 200);
    }
    return RepositoryResponse(data: {"body": "User not found"}, statusCode: 404);
  }

  Future<RepositoryResponse> deleteUser(String userId) async {
    await _database.collection('user').doc(userId).delete();
    return RepositoryResponse(data: {"body": "Success"}, statusCode: 200);
  }

  // Categories methods


}


