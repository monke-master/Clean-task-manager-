import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_arch/repository/api.dart';
import 'package:task_manager_arch/repository/repository_response.dart';
import 'package:http/http.dart' as http;

const String base ='http://localhost:8080';

void main() {
  Api api = Api();

  setUpAll(() async {

    // Добавление тестовых данных о пользователях
    Uri uri = Uri.parse("$base/user/1");
    await http.post(uri, body: {
      'email': 'get.me@gmail.com',
      'password': 'password',
      'registration_date': '2022-08-11 13:04:00'});
    uri = Uri.parse("$base/user/0");
    await http.post(uri, body: {
      'email': 'delete.me@gmail.com',
      'password': 'password',
      'registration_date': '2022-08-11 13:04:00'});
    uri = Uri.parse("$base/user/2");
    await http.post(uri, body: {
      'email': 'update.email@gmail.com',
      'password': 'password',
      'registration_date': '2022-08-11 13:04:00'});
    uri = Uri.parse("$base/user/3");
    await http.post(uri, body: {
      'email': 'update.password@gmail.com',
      'password': 'password',
      'registration_date': '2022-08-11 13:04:00'});

    // Добавление тестовых данных о категориях
    uri = Uri.parse("$base/category/0");
    await http.post(uri, body: {
      'user_id': '2',
      'title': 'delete me',
      'creation_date': '2022-09-11 11:39:00'});
    uri = Uri.parse("$base/category/1");
    await http.post(uri, body: {
      'user_id': '1',
      'title': 'get me',
      'creation_date': '2022-09-11 11:39:00'});
    uri = Uri.parse("$base/category/2");
    await http.post(uri, body: {
      'user_id': '1',
      'title': 'just category',
      'creation_date': '2022-09-11 11:39:00'
    });
    uri = Uri.parse("$base/category/3");
    await http.post(uri, body: {
      'user_id': '2',
      'title': 'Update title',
      'creation_date': '2022-09-11 11:39:00'
    });

    // Добавление тестовых задач
    uri = Uri.parse("$base/task/0");
    await http.post(uri, body: {
      'user_id': '2',
      'category_id': '2',
      'title': 'Delete this task',
      'creation_date': '2022-09-12 18:32:00',
      'date': '2022-10-12 18:32:00',
      'completed': '0'
    });
    uri = Uri.parse("$base/task/1");
    await http.post(uri, body: {
      'user_id': '1',
      'category_id': '1',
      'title': 'Get this task',
      'creation_date': '2022-09-12 18:32:00',
      'date': '2022-10-12 18:32:00',
      'completed': '0',
    });
    uri = Uri.parse("$base/task/2");
    await http.post(uri, body: {
      'user_id': '1',
      'title': 'Get this task in list',
      'creation_date': '2022-09-12 18:32:00',
      'date': '2022-10-12 18:32:00',
      'completed': '1',
    });
    uri = Uri.parse("$base/task/3");
    await http.post(uri, body: {
      'user_id': '2',
      'category_id': '1',
      'title': 'Category 1 task',
      'creation_date': '2022-09-12 18:32:00',
      'date': '2022-10-12 18:32:00',
      'completed': '0',
      'emailed': '1'
    });
    uri = Uri.parse("$base/task/4");
    await http.post(uri, body: {
      'user_id': '2',
      'title': 'Update title',
      'creation_date': '2022-09-12 18:32:00',
      'completed': '0',
    });
    uri = Uri.parse("$base/task/5");
    await http.post(uri, body: {
      'user_id': '2',
      'title': 'Update date',
      'creation_date': '2022-09-12 18:32:00',
      'completed': '0',
    });
    uri = Uri.parse("$base/task/6");
    await http.post(uri, body: {
      'user_id': '2',
      'title': 'Update completed',
      'creation_date': '2022-09-12 18:32:00',
      'completed': '0',
    });
    uri = Uri.parse("$base/task/7");
    await http.post(uri, body: {
      'user_id': '2',
      'title': 'Update category',
      'creation_date': '2022-09-12 18:32:00',
      'completed': '0',
    });
    uri = Uri.parse("$base/task/8");
    await http.post(uri, body: {
      'user_id': '2',
      'title': 'Update emailed',
      'creation_date': '2022-09-12 18:32:00',
      'completed': '0',
    });
    uri = Uri.parse("$base/task/9");
    await http.post(uri, body: {
      'user_id': '2',
      'title': 'Update repeating',
      'creation_date': '2022-09-12 18:32:00',
      'completed': '0',
    });


  });

  group("User data test", () {

    test("get user", () async {
      RepositoryResponse response = await api.getUser('1');
      var expected = {
        'id': '1',
        'email': 'get.me@gmail.com',
        'password': 'password',
        'registration_date': '2022-08-11 13:04:00'};
      expect(response.data, expected);
    });

    test("get non existing user", () async {
      RepositoryResponse response = await api.getUser('404');
      expect(response.statusCode, 404);
    });

    test("get user by email", () async {
      RepositoryResponse response = await api.getUserByEmail('get.me@gmail.com');
      var expected = {
        'id': '1',
        'email': 'get.me@gmail.com',
        'password': 'password',
        'registration_date': '2022-08-11 13:04:00'};
      expect(response.data, expected);
    });

    test('Add user', () async {
      Map<String, dynamic> data = {
        'email': 'add.me@gmail.com',
        'password': 'password',
        'registration_date': '2022-08-11 13:04:00'};
      RepositoryResponse response = await api.addUser('4', data);
      expect(response.statusCode, 200);
    });

    test("Delete user", () async {
      RepositoryResponse  response = await api.deleteUser('0');
      expect(response.statusCode, 200);
    });

    test("Delete non existing user", () async {
      RepositoryResponse  response = await api.deleteUser('404');
      expect(response.statusCode, 200);
    });

    test('Update user email', () async {
      Map<String, dynamic> data = {
        'email': 'new@gmail.com',
        'password': 'password'};
      RepositoryResponse response = await api.updateUser('2', data);
      expect(response.statusCode, 200);
    });

    test('Update user password', () async {
      Map<String, dynamic> data = {
        'email': 'update.password@gmail.com',
        'password': 'new_password'};
      RepositoryResponse response = await api.updateUser('3', data);
      expect(response.statusCode, 200);
    });
  });


  group("Category tests", () {
    test("get category", () async {
      RepositoryResponse response = await api.getCategory('1');
      var expected = {
        'category_id': '1',
        'user_id': '1',
        'title': 'get me',
        'creation_date': '2022-09-11 11:39:00'};
      expect(response.data, expected);
    });

    test("get non existing category", () async {
      RepositoryResponse response = await api.getCategory('404');
      expect(response.statusCode, 404);
    });

    test("Get user's categories", () async {
      RepositoryResponse response = await api.getCategoriesList('1');
      var expected = {
        '1' : {
          'user_id': '1',
          'title': 'get me',
          'creation_date': '2022-09-11 11:39:00'
        },
        '2' : {
          'user_id': '1',
          'title': 'just category',
          'creation_date': '2022-09-11 11:39:00'
        }
      };
      expect(response.data, expected);
    });

    test("Add category", () async {
      var data = {
        'user_id': '1',
        'title': 'just category',
        'creation_date': '2022-09-11 11:39:00'
      };
      RepositoryResponse response = await api.addCategory('4', data);
      expect(response.statusCode, 200);
    });

    test("Update category", () async {
      var data = {
        'title': 'new category',
      };
      RepositoryResponse response = await api.updateCategory('3', data);
      expect(response.statusCode, 200);
    });

    test("Delete category", () async {
      RepositoryResponse response = await api.deleteCategory('0');
      expect(response.statusCode, 200);
    });

    test("Delete non-existing category", () async {
      RepositoryResponse response = await api.deleteCategory('404');
      expect(response.statusCode, 200);
    });

  });


  group("Tasks tests", () {

    test("Get task", () async {
      RepositoryResponse response = await api.getTask('1');
      var expected = {
        'task_id': '1',
        'user_id': '1',
        'category_id': '1',
        'title': 'Get this task',
        'creation_date': '2022-09-12 18:32:00',
        'date': '2022-10-12 18:32:00',
        'completed': 0,
        'repeating': null,
        'emailed': null
      };
      expect(response.data, expected);
    });

    test("Get non existing task", () async {
      RepositoryResponse response = await api.getTask('404');
      expect(response.statusCode, 404);
    });

    test("Get user's tasks", () async {
      RepositoryResponse response = await api.getUserTasks('1');
      var expected = {
        '1': {
          'user_id': '1',
          'category_id': '1',
          'title': 'Get this task',
          'creation_date': '2022-09-12 18:32:00',
          'date': '2022-10-12 18:32:00',
          'completed': 0,
          'emailed': null,
          'repeating': null,
        },
        '2': {
          'user_id': '1',
          'category_id': null,
          'title': 'Get this task in list',
          'creation_date': '2022-09-12 18:32:00',
          'date': '2022-10-12 18:32:00',
          'completed': 1,
          'emailed': null,
          'repeating': null,
        }
      };
      expect(response.data, expected);
    });

    test("Get category's tasks", () async {
      RepositoryResponse response = await api.getCategoryTasks('1');
      var expected = {
        '1': {
          'user_id': '1',
          'category_id': '1',
          'title': 'Get this task',
          'creation_date': '2022-09-12 18:32:00',
          'date': '2022-10-12 18:32:00',
          'completed': 0,
          'emailed': null,
          'repeating': null,
        },
        '3': {
          'user_id': '2',
          'category_id': '1',
          'title': 'Category 1 task',
          'creation_date': '2022-09-12 18:32:00',
          'date': '2022-10-12 18:32:00',
          'completed': 0,
          'emailed': 1,
          'repeating': null,
        }
      };
      expect(response.data, expected);
    });

    test("Add task", () async {
      var data = {
        'user_id': '2',
        'title': 'Test adding task',
        'creation_date': '2022-09-12 18:32:00',
        'completed': '0',
      };
      RepositoryResponse response = await api.addTask('10', data);
      expect(response.statusCode, 200);
    });

    test("Add full task", () async {
      var data = {
        'user_id': '2',
        'category_id': '2',
        'title': 'Test adding full task',
        'creation_date': '2022-09-12 18:32:00',
        'date': '2022-09-16 22:32:00',
        'completed': '0',
        'emailed': '1',
        'repeating': '4356789'
      };
      RepositoryResponse response = await api.addTask('11', data);
      expect(response.statusCode, 200);
    });

    test("Update task's title", () async {
      var data = {
        'title': "new Title",
        'completed': '0'
      };
      RepositoryResponse response = await api.updateTask('4', data);
      expect(response.statusCode, 200);
    });

    test("Update task's date", () async {
      var data = {
        'title': 'Update date',
        'date': '2022-09-12 18:32:00',
        'completed': '0'
      };
      RepositoryResponse response = await api.updateTask('5', data);
      expect(response.statusCode, 200);
    });

    test("Update task's completed", () async {
      var data = {
        'title': 'Update completed',
        'completed': '1'
      };
      RepositoryResponse response = await api.updateTask('6', data);
      expect(response.statusCode, 200);
    });


    test("Update task's category", () async {
      var data = {
        'title': 'Update category',
        'category_id': '3',
        'completed': '0',
      };
      RepositoryResponse response = await api.updateTask('7', data);
      expect(response.statusCode, 200);
    });

    test("Update task's emailed", () async {
      var data = {
        'title': 'Update emailed',
        'completed': '0',
        'emailed': '1'
      };
      RepositoryResponse response = await api.updateTask('8', data);
      expect(response.statusCode, 200);
    });

    test("Update task's completed", () async {
      var data = {
        'title': 'Update repeating',
        'completed': '0',
        'repeating': '1500'
      };
      RepositoryResponse response = await api.updateTask('9', data);
      expect(response.statusCode, 200);
    });

  });


  tearDownAll(() async {
    for (int i = 0; i < 13; i++) {
      Uri uri = Uri.parse("$base/task/$i");
      await http.delete(uri);
    }
    for (int i = 0; i < 5; i++) {
      Uri uri = Uri.parse("$base/category/$i");
      await http.delete(uri);

    }
    for (int i = 0; i < 5; i++) {
      Uri uri = Uri.parse("$base/user/$i");
      await http.delete(uri);
    }

  });
}