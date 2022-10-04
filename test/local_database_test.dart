

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localstore/localstore.dart';
import 'package:task_manager_arch/repository/local_database.dart';
import 'package:task_manager_arch/models/data_response.dart';

void main() {

  Localstore store = Localstore.instance;
  LocalDatabase database = LocalDatabase();
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();

    database.init();

    // Данные пользователей для тестов
    store.collection('user').doc('-1').set({});
    store.collection("user").doc('0').set({
      "email": "delete.me@gmail.com",
      "password": "password",
      "registration_date": '2022-08-11 13:04:00'
    });
    store.collection("user").doc('1').set({
      "email": "get.me@gmail.com",
      "password": "password",
      "registration_date": '2022-08-11 13:04:00'
    });
    store.collection("user").doc('2').set({
      "email": "update.email@gmail.com",
      "password": "password",
      "registration_date": '2022-08-11 13:04:00'
    });
    store.collection("user").doc('3').set({
      "email": "update.password@gmail.com",
      "password": "password",
      "registration_date": '2022-08-11 13:04:00'
    });

    // Данные категорий для тестов
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
    store.collection("categories").doc('3').set({
      "user_id": "3",
      "title": "Edit title",
      "creation_date": '2022-08-11 13:04:00'
    });

    // Данные задач для тестов
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
    store.collection("tasks").doc('4').set({
      'user_id': '2',
      'title': 'Update title',
      'creation_date': '2022-08-11 13:04:00',
      'completed': 0,
    });
    store.collection("tasks").doc('5').set({
      'user_id': '2',
      'title': 'Update date',
      'creation_date': '2022-08-11 13:04:00',
      'completed': 0,
      'date': '2022-08-12 13:04:00',
    });
    store.collection("tasks").doc('6').set({
      'user_id': '2',
      'title': 'Update category',
      'creation_date': '2022-08-11 13:04:00',
      'completed': 0,
      'category_id': '2'
    });
    store.collection("tasks").doc('7').set({
      'user_id': '2',
      'title': 'Update emailed',
      'creation_date': '2022-08-11 13:04:00',
      'completed': 0,
      'emailed': 0
    });
    store.collection("tasks").doc('8').set({
      'user_id': '2',
      'title': 'Update repeating',
      'creation_date': '2022-08-11 13:04:00',
      'completed': 0,
      'repeating': 123
    });
    store.collection("tasks").doc('9').set({
      'user_id': '2',
      'title': 'Update completed',
      'creation_date': '2022-08-11 13:04:00',
      'completed': 0,
    });

    store.collection('config').doc('1').set({
      'user_id': '2',
      'theme': 'light'
    });

  });

  group("user tests", () {

    test("Get user with no data", () async {
      var res = await database.getUser("-1");
      expect({}, res.data);
    });
    test("get user", () async {
      var result = await database.getUser('1');
      var expected = {
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
      var result = await store.collection('user').doc('4').get();
      expect(result, data);
    });

    test("Update user's email", () async {
      var data = {
        'email': "new.email@gmail.com",
        "password": "password",
        "registration_date": '2022-08-11 13:04:00'
      };
      database.putUser('2', data);
      var result = await store.collection('user').doc('2').get();
      expect(result, data);
    });

    test("Update user's password", () async {
      var data = {
        'email': "update.password@gmail.com",
        "password": "new_pass",
        "registration_date": '2022-08-11 13:04:00'
      };
      database.putUser('3', data);
      var result = await store.collection('user').doc('3').get();
      expect(result, data);
    });

    test("Delete non existing user", () async {
      DataResponse response = await database.deleteUser('56789');
      expect(response.statusCode, 200);
    });
  });



  group("Categories test", () {

    test("Get category", () async {
      var result = await database.getCategory('1');
      var expected = {
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
      expect(result.data, expected);
    });

    test("Get non-existing user's categories", () async {
      var result = await database.getCategoriesList("404");
      expect(result.statusCode, 404);
    });

    test("Edit category title", () async {
      var data = {
        "user_id": "2",
        "title": "New title",
        "creation_date": '2022-08-11 13:04:00'
      };
      database.putCategory('3', data);
      var result = await store.collection('categories').doc('3').get();
      expect(data, result);
    });

  });

  group("Tasks tests", ()  {

    test("Get task", () async {
      var result = await database.getTask('1');
      var expected = {
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
      expect(result.data, expected);
    });

    test("Get category's tasks", () async {
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
      expect(result.data, expected);
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
      var data = {
        'user_id': '2',
        'title': 'Update title',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
      };
      database.putTask('4', data);
      var result = await store.collection("tasks").doc('4').get();
      expect(result, data);
    });

    test("Update task's date", () async {
      var data = {
        'user_id': '2',
        'title': 'Update date',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'date': '2022-08-12 13:04:00',
      };
      database.putTask('5', data);
      var result = await store.collection("tasks").doc('5').get();
      expect(result, data);
    });

    test("Update task's category", () async {
      var data = {
        'user_id': '2',
        'title': 'Update category',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'category_id': '2'
      };
      database.putTask('6', data);
      var result = await store.collection("tasks").doc('6').get();
      expect(result, data);
    });

    test("Update task's emailed", () async {
      var data = {
        'user_id': '2',
        'title': 'Update emailed',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'emailed': 0
      };
      database.putTask('7', data);
      var result = await store.collection("tasks").doc('7').get();
      expect(result, data);
    });

    test("Update task's repeating", () async {
      var data = {
        'user_id': '2',
        'title': 'Update repeating',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
        'repeating': 123
      };
      database.putTask('8', data);
      var result = await store.collection("tasks").doc('8').get();
      expect(result, data);
    });

    test("Update task's completed", () async {
      var data = {
        'user_id': '2',
        'title': 'Update completed',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0,
      };
      database.putTask('9', data);
      var result = await store.collection("tasks").doc('9').get();
      expect(result, data);
    });

  });

  group('Config data tests', () {


    test('Get config', () async {
      var res = await database.getConfig();
      var expected = {
        'user_id': '2',
        'theme': 'light'
      };
      expect(res.data, expected);
    });


    test("Update config's user id", () async {
      var newData = {
        'user_id': '21'
      };
      var expected = {
        'user_id': '21',
        'theme': 'light'
      };
      await database.putConfig(newData);
      var result = await store.collection('config').doc('1').get();
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


  });

  tearDownAll(() async {
    for (int id = 0; id < 15; id++) {
      await store.collection('tasks').doc('$id').delete();
      await store.collection('categories').doc('$id').delete();
      await store.collection('user').doc('$id').delete();
      await store.collection('config').doc('$id').delete();
    }
  });



}