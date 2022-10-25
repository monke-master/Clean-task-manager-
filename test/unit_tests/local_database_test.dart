import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localstore/localstore.dart';
import 'package:task_manager_arch/repository/local_database.dart';
import 'package:task_manager_arch/models/data_response.dart';

@TestOn("android")
void main() {


  Localstore store = Localstore.instance;
  LocalDatabase database = LocalDatabase();
  WidgetsFlutterBinding.ensureInitialized();

  database.init();

  group("User tests", () {

    test("Get user with no data", () async {
      store.collection('users').doc('-1').set({});

      var res = await database.getUser("-1");

      var expected = {
        'id': '-1'
      };
      expect(res.data, expected);
    });

    test("get user", () async {
      await store.collection("users").doc('1').set({
        "email": "get.me@gmail.com",
        "password": "password",
        "registration_date": '2022-08-11 13:04:00'
      });

      var result = await database.getUser('1');

      var expected = {
        'id': '1',
        "email": "get.me@gmail.com",
        "password": "password",
        "registration_date": '2022-08-11 13:04:00'
      };
      expect(result.data, expected);
    });

    test("get non existing user", () async {
      var result = await database.getUser('404');

      expect(result.statusCode, 404);
    });

    test('Add user', () async {
      var data = {
        'email': "new.user@gmail.com",
        "password": "password",
        "registration_date": '2022-08-11 13:04:00'
      };

      await database.putUser('4', data);


      var result = await store.collection('users').doc('4').get();
      expect(result, data);
    });

    test("Update user's email", () async {
      store.collection("users").doc('2').set({
        "email": "update.email@gmail.com",
        "password": "password",
        "registration_date": '2022-08-11 13:04:00'
      });
      var data = {
        'email': "new.email@gmail.com",
        "password": "password",
      };

      database.putUser('2', data);

      var result = await store.collection('users').doc('2').get();
      var expectedUser = {
        'id': '2',
        'email': "new.email@gmail.com",
        "password": "password",
        "registration_date": '2022-08-11 13:04:00'
      };
      expect(result, expectedUser);
    });

    test("Update user's password", () async {
      store.collection("users").doc('3').set({
        "email": "update.password@gmail.com",
        "password": "password",
        "registration_date": '2022-08-11 13:04:00'
      });

      var updatedData = {
        'email': "update.password@gmail.com",
        "password": "new_pass",
      };
      await database.putUser('3', updatedData);

      var result = await store.collection('users').doc('3').get();
      var expectedUser = {
        'id': '3',
        'email': "update.password@gmail.com",
        "password": "new_pass",
        "registration_date": '2022-08-11 13:04:00'
      };
      expect(result, expectedUser);
    });

    test("Delete user", () async {
      store.collection("user").doc('0').set({
        "email": "delete.me@gmail.com",
        "password": "password",
        "registration_date": '2022-08-11 13:04:00'
      });

      var response = await database.deleteUser('0');

      Timer(const Duration(seconds: 2), () async {
        var getUserResponse = await store.collection('users').doc('0').get();
        expect(response.statusCode, 200);
        expect(getUserResponse, null);
      });
    });

    test("Delete non-existing user", () async {
      var response = await database.deleteUser('0');

      expect(response.statusCode, 404);
    });

    tearDownAll(() async {
      for (int id = 0; id < 5; id++) {
        await store.collection('users').doc('$id').delete();
      }
    });

  });

  group("Categories test", () {

    test("Get category", () async {
      store.collection("categories").doc('1').set({
        "user_id": "1",
        "title": "Get me ",
        "creation_date": '2022-08-11 13:04:00'
      });

      var result = await database.getCategory('1');

      var expected = {
        "category_id": '1',
        "user_id": "1",
        "title": "Get me ",
        "creation_date": '2022-08-11 13:04:00'
      };
      expect(result.data, expected);
    });

    test("Get non existing category", () async {
      var result = await database.getCategory('404');

      expect(result.statusCode, 404);
    });

    test("Add category", () async {
      var data = {
        "user_id": "2",
        "title": "New category",
        "creation_date": '2022-08-11 13:04:00'
      };

      await database.putCategory('4', data);

      var result = await store.collection('categories').doc('4').get();
      expect(data, result);
    });

    test("Get categories list", () async {
      store.collection("categories").doc('1').set({
        "user_id": "1",
        "title": "Get me ",
        "creation_date": '2022-08-11 13:04:00'
      });
      store.collection("categories").doc('2').set({
        "user_id": "1",
        "title": "Get me in list",
        "creation_date": '2022-08-11 13:04:00'
      });

      var result = await database.getCategoriesList("1");

      var expected = {
        '1': {
            "user_id": "1",
            "title": "Get me ",
            "creation_date": '2022-08-11 13:04:00'
        },
        '2': {
          "user_id": "1",
          "title": "Get me in list",
          "creation_date": '2022-08-11 13:04:00'
        },
      };
      expect(result, expected);
    });

    test("Get non-existing user's categories", () async {
      var result = await database.getCategoriesList("404");

      expect(result, {});
    });

    test("Edit category title", () async {
      store.collection("categories").doc('3').set({
        "user_id": "3",
        "title": "Edit title",
        "creation_date": '2022-08-11 13:04:00'
      });
      var data = {
        "title": "New title",
      };

      database.putCategory('3', data);

      var result = await store.collection('categories').doc('3').get();
      var expectedTitle = {
        'category_id': '3',
        "user_id": "3",
        "title": "New title",
        "creation_date": '2022-08-11 13:04:00'
      };
      expect(result, expectedTitle);
    });

    test("Delete category", () async {
      store.collection("categories").doc('0').set({
        "user_id": "0",
        "title": "Delete category",
        "creation_date": '2022-08-11 13:04:00'
      });

      var response = await database.deleteCategory('0');

      Timer(const Duration(seconds: 2), () async {
        var getCategoryResponse = await store.collection('categories').doc('0').get();
        expect(response.statusCode, 200);
        expect(getCategoryResponse, null);
      });
    });

    test("Delete non-existing category", () async {
      var response = await database.deleteCategory('0');

      expect(response.statusCode, 404);
    });

    tearDownAll(() async {
      for (int id = 0; id < 15; id++) {
        await store.collection('categories').doc('$id').delete();
      }
    });
  });

  group("Tasks tests", ()  {

    test("Get task", () async {
      store.collection("tasks").doc('1').set({
        'user_id': '1',
        'title': 'Get me',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0
      });

      var result = await database.getTask('1');

      var expected = {
        'task_id': '1',
        'user_id': '1',
        'title': 'Get me',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0
      };
      expect(result.data, expected);
    });

    test("Get non-existing task", () async {
      var result = await database.getTask('404');

      expect(result.statusCode, 404);
    });

    test("Get user's tasks", () async {
      store.collection("tasks").doc('1').set({
        'user_id': '1',
        'title': 'Get me',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0
      });
      store.collection("tasks").doc('2').set({
        'user_id': '1',
        'title': 'Get me in list',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'category_id': '1'
      });

      var result = await database.getUserTasks('1');

      var expected = {
        "1": {
          'user_id': '1',
          'title': 'Get me',
          'creation_date': '2022-08-11 13:04:00',
          'completed': 0
        },
        "2" : {
          'user_id': '1',
          'title': 'Get me in list',
          'creation_date': '2022-08-11 13:04:00',
          'completed': 0,
          'category_id': '1'
        }
      };
      expect(result, expected);
    });

    test("Get non-existing user's tasks", () async {
      var result = await database.getUserTasks("404");

      expect(result, {});
    });

    test("Get category's tasks", () async {
      store.collection("tasks").doc('2').set({
        'user_id': '1',
        'title': 'Get me in list',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'category_id': '1'
      });
      store.collection("tasks").doc('3').set({
        'user_id': '2',
        'title': 'Get me in list',
        'creation_date': '2022-08-11 13:04:00',
        'date': '2022-08-12 13:04:00',
        'completed': 0,
        'category_id': '1',
        'emailed': 1,
        'repeating': 1500,
      });

      var result = await database.getCategoryTasks("1");

      var expected = {
        "2": {
          'user_id': '1',
          'title': 'Get me in list',
          'creation_date': '2022-08-11 13:04:00',
          'completed': 0,
          'category_id': '1'
        },
        "3" : {
          'user_id': '2',
          'title': 'Get me in list',
          'creation_date': '2022-08-11 13:04:00',
          'date': '2022-08-12 13:04:00',
          'completed': 0,
          'category_id': '1',
          'emailed': 1,
          'repeating': 1500,
        }
      };
      expect(result, expected);
    });

    test("Get non-existing category's tasks", () async {
      var result = await database.getCategoryTasks("404");

      expect(result, {});
    });

    test("Add task", () async {
      var data = {
        'user_id': '2',
        'title': 'New task',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0
      };

      await database.putTask('10', data);

      var result = await store.collection('tasks').doc('10').get();
      expect(result, data);
    });

    test("Add full task", () async {
      var data = {
        'task_id': '10',
        'user_id': '2',
        'title': 'Task with all fields',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'emailed': 1,
        'repeating': 200,
        'category_id': '2',
      };

      database.putTask('10', data);

      var result = await store.collection('tasks').doc('10').get();
      expect(result, data);
    });

    test("Update task's title", () async {
      store.collection("tasks").doc('4').set({
        'user_id': '2',
        'title': 'Update title',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
      });
      var data = {
        'title': 'Update title',
      };

      database.putTask('4', data);

      var result = await store.collection("tasks").doc('4').get();
      var expectedTask = {
        'task_id': '4',
        'user_id': '2',
        'title': 'Update title',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
      };
      expect(result, expectedTask);
    });

    test("Update task's date", () async {
      store.collection("tasks").doc('5').set({
        'user_id': '2',
        'title': 'Update date',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'date': '2022-08-12 13:04:00',
      });
      var data = {
        'date': '2022-08-12 13:04:00',
      };

      database.putTask('5', data);

      var result = await store.collection("tasks").doc('5').get();
      var expectedTask = {
        'task_id': '5',
        'user_id': '2',
        'title': 'Update date',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'date': '2022-08-12 13:04:00',
      };
      expect(result, expectedTask);
    });

    test("Update task's category", () async {
      store.collection("tasks").doc('6').set({
        'user_id': '2',
        'title': 'Update category',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'category_id': '2'
      });
      var data = {
        'category_id': '2'
      };

      database.putTask('6', data);

      var result = await store.collection("tasks").doc('6').get();
      var expectedTask = {
        'task_id': '6',
        'user_id': '2',
        'title': 'Update category',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'category_id': '2'
      };
      expect(result, expectedTask);
    });

    test("Update task's emailed", () async {
      store.collection("tasks").doc('7').set({
        'user_id': '2',
        'title': 'Update emailed',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'emailed': 0
      });
      var data = {
        'emailed': 0
      };

      database.putTask('7', data);

      var result = await store.collection("tasks").doc('7').get();
      var expectedTask = {
        'task_id': '7',
        'user_id': '2',
        'title': 'Update emailed',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'emailed': 0
      };
      expect(result, expectedTask);
    });

    test("Update task's repeating", () async {
      store.collection("tasks").doc('8').set({
        'user_id': '2',
        'title': 'Update repeating',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'repeating': 123
      });
      var data = {
        'repeating': 123
      };

      database.putTask('8', data);

      var result = await store.collection("tasks").doc('8').get();
      var expectedTask = {
        'task_id': '8',
        'user_id': '2',
        'title': 'Update repeating',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'repeating': 123
      };
      expect(result, expectedTask);
    });

    test("Update task's completed", () async {
      store.collection("tasks").doc('9').set({
        'user_id': '2',
        'title': 'Update completed',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
      });
      var data = {
        'completed': 0,
      };

      database.putTask('9', data);

      var result = await store.collection("tasks").doc('9').get();
      var expectedTask = {
        'task_id': '9',
        'user_id': '2',
        'title': 'Update completed',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
      };
      expect(result, expectedTask);
    });

    test("Delete non-existing task", () async {
      var response = await database.deleteTask('404');

      expect(response.statusCode, 404);
    });

    test("Delete task", () async {
      store.collection("tasks").doc('0').set({
        'user_id': '0',
        'title': 'Get me',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0
      });
      var response = await database.deleteTask('0');

      Timer(const Duration(seconds: 2), () async {
        var getUserResponse = await store.collection('tasks').doc('0').get();
        expect(response.statusCode, 200);
        expect(getUserResponse, null);
      });
    });

    test("Delete non-existing task", () async {
      var response = await database.deleteTask('404');

      expect(response.statusCode, 404);
    });

    tearDownAll(() async {
      for (int id = 0; id < 15; id++) {
        await store.collection('tasks').doc('$id').delete();
      }
    });
  });

  group('Config data tests', () {

    test('Get config', () async {
      store.collection('config').doc('1').set({
        'user_id': '2',
        'theme': 'light'
      });

      var res = await database.getConfig();

      var expected = {
        'user_id': '2',
        'theme': 'light'
      };
      expect(res, expected);
    });

    test("Update config's user id", () async {
      store.collection('config').doc('1').set({
        'user_id': '2',
        'theme': 'light'
      });
      var newData = {
        'user_id': '21'
      };

      await database.putConfig(newData);

      var result = await store.collection('config').doc('1').get();
      var expected = {
        'user_id': '21',
        'theme': 'light'
      };
      expect(expected, result);
    });

    test('Put config', () async {
      var data = {
        'user_id': '22',
        'theme': 'system'
      };

      await database.putConfig(data);

      var res = await store.collection('config').doc('1').get();
      expect(res, data);
    });

    test("Delete config", () async {
      store.collection('config').doc('1').set({
        'user_id': '2',
        'theme': 'light'
      });

      var response = await database.deleteConfig();

      Timer(const Duration(seconds: 2), () async {
        var getUserResponse = await store.collection('config').doc('0').get();
        expect(response.statusCode, 200);
        expect(getUserResponse, null);
      });
    });

    tearDownAll(() async {
      await store.collection('config').doc('0').delete();
    });

  });

  group("Error data tests", () {

    test("Add an error", () async {
      var data = {
        'type': 'delete',
        'collection': 'tasks',
        'body': {
          'id': '148'
        }
      };

      await database.putError(data);

      var result = await store.collection('errors').doc('0').get();
      expect(result, data);
    });

    test("Add two errors", () async {
      var error1 = {
        'type': 'delete',
        'collection': 'tasks',
        'body': {
          'id': '148'
        }
      };
      var error2 = {
        'type': 'delete',
        'collection': 'tasks',
        'body': {
          'id': '148'
        }
      };

      await database.putError(error1);
      await database.putError(error2);

      var result1 = await store.collection('errors').doc('0').get();
      var result2 = await store.collection('errors').doc('1').get();
      expect(result1, error1);
      expect(result2, error2);
    });

    test("Get errors list", () async {
      await store.collection('errors').doc('0').set({
        'type': 'put',
        'collection': 'categories',
        'body': {
          'id': '1',
        }
      });
      await store.collection('errors').doc('1').set({
        'type': 'put',
        'collection': 'categories',
        'body': {
          'id': '2',
        }
      });

      var result = await database.getErrorsList();

      var expected = {
        '0': {
          'type': 'put',
          'collection': 'categories',
          'body': {
            'id': '1',
          }
        },
        '1': {
          'type': 'put',
          'collection': 'categories',
          'body': {
            'id': '2',
          }
        }
      };
      expect(result, expected);
    });

    test("Get empty errors list", () async {
      var result = await database.getErrorsList();

      expect(result, {});
    });

    test("Delete error", () async {
      var data = {
        'type': 'put',
        'collection': 'categories',
        'body': {
          'id': '1',
        }
      };
      await store.collection('errors').doc('0').set(data);

      var result = await database.deleteError('0');

      Timer(const Duration(seconds: 1), () async {
        var checkError = await store.collection('errors').doc('0').get();
        expect(result.statusCode, 200);
        expect(checkError, null);
      });
    });

    tearDown(() async {
      for (int id = 0; id < 5; id++) {
        await store.collection('errors').doc('$id').delete();
      }
    });

  });





}