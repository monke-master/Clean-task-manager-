import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:localstore/localstore.dart';
import 'package:task_manager_arch/models/category.dart';
import 'package:task_manager_arch/models/data_response.dart';
import 'package:task_manager_arch/repository/local_database.dart';
import 'package:task_manager_arch/service/service.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_arch/models/task.dart';
import 'package:task_manager_arch/models/user.dart';
import 'package:task_manager_arch/repository/api.dart';
import 'package:task_manager_arch/repository/in_memory_cache.dart';

@TestOn("android")
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  InMemoryCache cache = InMemoryCache();
  LocalDatabase localDatabase = LocalDatabase();
  localDatabase.init();
  Api api = Api();


  group("No account initialize test", () {

    test("Initialize test", () async {
      Service service = Service(cache, api, localDatabase);
      await service.initialize();

      var expectedConfig = {
        'user_id': 'guest',
        'theme': 'system',
        'language': Platform.localeName,
        'notify_about_sign_up': true
      };

      var configRes = await localDatabase.getConfig();
      var userRes = await localDatabase.getUser('guest');

      expect(configRes.data, expectedConfig);
      expect(userRes.data, {'id': 'guest'});
      expect(cache.getUser(), {'id': 'guest'});
    });

    tearDownAll(() async {
      await localDatabase.deleteUser("guest");
      await localDatabase.deleteConfig();
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteUser('$id');
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        cache.deleteUser();
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
      }
    });
  });


  group("Guest user initialize test", () {

    setUpAll(() {
      localDatabase.putConfig({
        "user_id": 'guest',
        'theme': 'dark',
        "language": "russian",
        'notify_about_sign_up': false
      });
      localDatabase.putUser("guest", {});
      localDatabase.putCategory('1', {
        "user_id": "guest",
        "title": "Get me ",
        "creation_date": '2022-08-11 13:04:00'
      });
      localDatabase.putTask('1', {
        'user_id': 'guest',
        'title': 'Get me',
        'creation_date': '2022-08-11 13:04:00',
        'completed': '0'
      });
    });

    test("Init test", () async {
      Service service = Service(cache, api, localDatabase);
      await service.initialize();

      var expectedUser = {
        "id": "guest"
      };
      var expectedTasks = {
        '1': {
          'user_id': 'guest',
          'title': 'Get me',
          'creation_date': '2022-08-11 13:04:00',
          'completed': '0',
        }
      };
      var expectedCategories = {
        '1': {
          "user_id": "guest",
          "title": "Get me ",
          "creation_date": '2022-08-11 13:04:00',
        }
      };

      expect(cache.getCategoriesList(), expectedCategories);
      expect(cache.getUserTasks(), expectedTasks);
      expect(cache.getUser(), expectedUser);
    });

    tearDownAll(() async {
      localDatabase.deleteUser("guest");
      await localDatabase.deleteConfig();
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteUser('$id');
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        cache.deleteUser();
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
      }
    });
  });


  group("User with account initialize tests", () {
    setUpAll(() {
      var userData = {
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      localDatabase.putConfig({
        "user_id": '1',
        'theme': 'dart'});
      localDatabase.putUser("1", userData);
      localDatabase.putCategory('1', {
        "user_id": "1",
        "title": "Get me",
        "creation_date": '2022-08-11 13:04:00'
      });
      localDatabase.putTask('1', {
        'user_id': '1',
        'title': 'Get me',
        'creation_date': '2022-08-11 13:04:00',
        'completed': '0'
      });
    });

    test("Init", () async {
      Service service = Service(cache, api, localDatabase);
      await service.initialize();

      var expectedUser = {
        "id": "1",
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      var expectedTasks = {
        '1': {
          'user_id': '1',
          'title': 'Get me',
          'creation_date': '2022-08-11 13:04:00',
          'completed': '0'
        }
      };
      var expectedCategories = {
        '1': {
          "user_id": "1",
          "title": "Get me",
          "creation_date": '2022-08-11 13:04:00'
        }
      };

      expect(cache.getCategoriesList(), expectedCategories);
      expect(cache.getUserTasks(), expectedTasks);
      expect(cache.getUser(), expectedUser);
    });

    tearDownAll(() async {
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteUser('$id');
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        await localDatabase.deleteConfig();
      }
    });
  });

  group("Sign up test", () {

    List<String> ids = [];

    setUpAll(() {
      localDatabase.putConfig({
        "user_id": 'guest',
        'theme': 'dark',
        "language": "russian",
        'notify_about_sign_up': false
      });
      localDatabase.putUser("guest", {});
      localDatabase.putCategory('1', {
        "user_id": "guest",
        "title": "Get me ",
        "creation_date": '2022-08-11 13:04:00'
      });
      localDatabase.putTask('1', {
        'user_id': 'guest',
        'title': 'Get me',
        'creation_date': '2022-08-11 13:04:00',
        'completed': '0'
      });
    });

    test("Sign up test", () async {
      Service service = Service(cache, api, localDatabase);
      await service.initialize();

      String email = "email@mail.ru";
      String password = "password";
      DateTime registrationDate = DateTime.parse("2022-08-11 13:04:00");
      String id = Object.hash(email, password, registrationDate).toString();
      User user = User(
          id: id,
          email: email,
          password: password,
          registrationDate: registrationDate);

      var signUpResponse = await service.signUp(user);
      ids.add(id);

      var expectedUser = {
        "id": id,
        'password': password,
        'email': email,
        'registration_date': registrationDate.toString()
      };
      var expectedTasks = {
        '1': {
          'user_id': id,
          'title': 'Get me',
          'creation_date': '2022-08-11 13:04:00',
          'completed': '0'
        }
      };
      var expectedCategories = {
        '1': {
          "user_id": id,
          "title": "Get me ",
          "creation_date": '2022-08-11 13:04:00'
        }
      };
      var expectedConfig = {
        "user_id": id,
        'theme': 'dark',
        "language": "russian",
        'notify_about_sign_up': false
      };

      var configRes = await localDatabase.getConfig();
      var apiRes = await api.getUser(id);

      expect(signUpResponse.statusCode, 200);
      expect(cache.getCategoriesList(), expectedCategories);
      expect(cache.getUserTasks(), expectedTasks);
      expect(cache.getUser(), expectedUser);
      expect(configRes.data, expectedConfig);
      expect(apiRes.data, expectedUser);
    });

    tearDownAll(() async {
      cache.deleteUser();
      var res = await localDatabase.deleteConfig();
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
        await api.deleteTask('$id');
        await api.deleteCategory('$id');
      }

      for (String id in ids) {
        await localDatabase.deleteUser(id);
        await api.deleteUser(id);
      }
    });
  });

  group("Authenticated user CRUD tests", () {
    Service service = Service(cache, api, localDatabase);

    setUp(() async {
      var userData = {
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      await localDatabase.putConfig({
        "user_id": '1',
        'theme': 'dart',
        'language': "en_US",
        'notify_about_sign_up': false
      });
      await localDatabase.putUser("1", userData);
      await api.addUser('1', userData);
      await service.initialize();
    });

    test("Get user", () async {
      User expected = User(
          id: '1',
          email: "email@mail.ru",
          password: "strong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));
      var result = service.getUser();
      expect(result, expected);
    });

    test("Update user's email test", () async {
      User newUser = User(
          id: '1',
          email: "new.email@mail.ru",
          password: "strong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));

      var res = await service.updateUser(newUser);
      var localDBRes = await localDatabase.getUser('1');
      var cacheRes = cache.getUser();
      var apiRes = await api.getUser('1');

      var expectedUserData = {
        'id': '1',
        "email": "new.email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };

      expect(res.statusCode, 200);
      expect(cacheRes, expectedUserData);
      expect(localDBRes.data, expectedUserData);
      expect(apiRes.data, expectedUserData);
    });

    test("Update user's password test", () async {
      User newUser = User(
          id: '1',
          email: "email@mail.ru",
          password: "mega_strong_password",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));

      var res = await service.updateUser(newUser);
      var localDBRes = await localDatabase.getUser('1');
      var cacheRes = cache.getUser();
      var apiRes = await api.getUser('1');

      var expectedUserData = {
        'id': "1",
        "email": "email@mail.ru",
        'password': "mega_strong_password",
        'registration_date': '2022-08-11 13:04:00'
      };
      expect(res.statusCode, 200);
      expect(cacheRes, expectedUserData);
      expect(localDBRes.data, expectedUserData);
      expect(apiRes.data, expectedUserData);
    });

    test("Delete user", () async {
      var deleteResponse = await service.deleteUser();

      var localeUserRes = await localDatabase.getUser('1');
      var localeConfigRes = await localDatabase.getConfig();
      var apiRes = await api.getUser('1');

      var expectedConfig = {
        "user_id": 'guest',
        'theme': 'dart',
        'language': "en_US",
        'notify_about_sign_up': false
      };
      expect(deleteResponse.statusCode, 200);
      expect(cache.getUser(), {});
      expect(localeUserRes.data, {"body": "User not found"});
      expect(localeConfigRes.data, expectedConfig);
      expect(apiRes.statusCode, 404);
    });

    tearDown(() async {
      cache.deleteUser();
      await localDatabase.deleteConfig();
      await localDatabase.deleteUser('1');
      await api.deleteUser('1');
      for (int id = 0; id < 15; id++) {
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
      }
    });
  });

  group("Wrong-authenticated user CRUD tests", () {

    Service service = Service(cache, api, localDatabase);
    setUp(() async {
      var localUserData = {
        "email": "email@mail.ru",
        'password': "wrong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      var webUserData = {
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      await localDatabase.putConfig({
        "user_id": '1',
        'theme': 'dart',
        'language': "en_US",
        'notify_about_sign_up': false
      });
      await localDatabase.putUser("1", localUserData);
      await api.addUser('1', webUserData);
      await service.initialize();

    });

    test("Get user", () async {
      var result = service.getUser();
      User expectedUser = User(
          id: '1',
          email: "email@mail.ru",
          password: "wrong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));
      expect(result, expectedUser);
    });

    test("Update user's password", () async {
      User newUser = User(
          id: '1',
          email: "email@mail.ru",
          password: "strong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));

      var apiResponse = await service.updateUser(newUser);
      var ldbResponse = await localDatabase.getUser('1');
      var apiGetResponse = await api.getUser('1');

      var expectedUserData = {
        'id': '1',
        "email": "email@mail.ru",
        'password': "wrong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      var expectedWebUserData = {
        'id': '1',
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      var expectedResponse = DataResponse(
          data: {"body": "Invalid login data"} ,
          statusCode: 401);
      expect(apiResponse, expectedResponse);
      expect(cache.getUser(), expectedUserData);
      expect(ldbResponse.data, expectedUserData);
      expect(apiGetResponse.data, expectedWebUserData);
    });

    test("Update user's email", () async {
      User newUser = User(
          id: '1',
          email: "new_email@mail.ru",
          password: "wrong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));

      var apiResponse = await service.updateUser(newUser);
      var ldbResponse = await localDatabase.getUser('1');
      var apiGetResponse = await api.getUser('1');

      var expectedUserData = {
        'id': '1',
        "email": "email@mail.ru",
        'password': "wrong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      var expectedWebUserData = {
        'id': '1',
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      var expectedResponse = DataResponse(
          data: {"body": "Invalid login data"} ,
          statusCode: 401);
      expect(apiResponse, expectedResponse);
      expect(cache.getUser(), expectedUserData);
      expect(ldbResponse.data, expectedUserData);
      expect(apiGetResponse.data, expectedWebUserData);
    });

    test("Delete user", () async {
      var response = await service.deleteUser();
      var ldbResponse = await localDatabase.getUser('1');
      var apiGetResponse = await api.getUser('1');

      var expectedUserData = {
        'id': '1',
        "email": "email@mail.ru",
        'password': "wrong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      var expectedWebUserData = {
        'id': '1',
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      var expectedResponse = DataResponse(
          data: {"body": "Invalid login data"} ,
          statusCode: 401);
      expect(response, expectedResponse);
      expect(cache.getUser(), expectedUserData);
      expect(ldbResponse.data, expectedUserData);
      expect(apiGetResponse.data, expectedWebUserData);
    });

    tearDown(() async {
      cache.deleteUser();
      await localDatabase.deleteConfig();
      await localDatabase.deleteUser('1');
      await api.deleteUser('1');
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteUser('$id');
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
      }
    });
  });

  group("Guest user CRUD tests", () {
    Service service = Service(cache, api, localDatabase);

    setUpAll(() async {
      var localUserData = {
        'id': "guest"
      };
      await localDatabase.putConfig({
        "user_id": 'guest',
        'theme': 'dart',
        'language': "en_US",
        'notify_about_sign_up': false
      });
      await localDatabase.putUser("guest", localUserData);
      await service.initialize();

    });

    test("Get user", () async {
      var result = service.getUser();
      User expectedUser = User(
          id: 'guest',
          email: null,
          password: null,
          registrationDate: null);
      expect(result, expectedUser);
    });

    test("Delete user", () async {
      var response = await service.deleteUser();

      Timer(const Duration(seconds: 1), expectAsync0(() async {
        var ldbResponse = await localDatabase.getUser('guest');
        var configResponse = await localDatabase.getConfig();

        var expectedConfig = {
          'user_id': 'guest',
        };
        expect(response.statusCode, 200);
        expect(cache.getUser(), {});
        expect(ldbResponse.statusCode, 404);
        expect(configResponse.data, expectedConfig);
      }, count: 1));

    });

  });

  group("Authenticated user's Category CRUD tests", () {
    Service service = Service(cache, api, localDatabase);

    setUp(() async {
      var userData = {
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      await localDatabase.putConfig({
        "user_id": '1',
        'theme': 'dart',
        'language': "en_US",
        'notify_about_sign_up': false
      });
      await localDatabase.putUser("1", userData);
      await api.addUser('1', userData);

      var category0 = {
        'title': 'Delete me',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00'
      };
      var category1 = {
        'title': 'Get me',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00'
      };
      var category2 = {
        'title': 'Update me',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00'
      };

      await localDatabase.putCategory('0', category0);
      await api.addCategory('0', category0);
      await localDatabase.putCategory('1', category1);
      await api.addCategory('1', category1);
      await localDatabase.putCategory('2', category2);
      await api.addCategory('2', category2);



      await service.initialize();
    });

    test("Get category", () async {
      Category result = service.getCategory('1')!;

      Category expectedCategory = Category(
          categoryId: '1',
          userId: '1',
          title: 'Get me',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));
      expect(result, expectedCategory);
    });

    test("Get categories list", () async {
      List<Category> result = service.getCategoriesList();

      Category category0 = Category(
          categoryId: '0',
          userId: '1',
          title: 'Delete me',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));
      Category category1 = Category(
          categoryId: '1',
          userId: '1',
          title: 'Get me',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));
      Category category2 = Category(
          categoryId: '2',
          userId: '1',
          title: 'Update me',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));
      expect(result, [category0, category1, category2]);
    });

    test("Add category", () async {
      Category newCategory = Category(
          categoryId: '3',
          userId: '1',
          title: 'New category',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));

      var serviceResponse = await service.addCategory(newCategory);
      var cacheResult = cache.getCategory('3');
      var ldbResult = await localDatabase.getCategory('3');
      var apiResult = await api.getCategory('3');

      var expectedCategory = {
        'category_id': '3',
        'title': 'New category',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00.000'
      };

      expect(serviceResponse.statusCode, 200);
      expect(cacheResult, expectedCategory);
      expect(ldbResult.data, expectedCategory);
      expect(apiResult.data, expectedCategory);
    });

    test("Update category", () async {
      Category newCategory = Category(
          categoryId: '2',
          userId: '1',
          title: 'New title',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));

      var serviceResponse = await service.updateCategory(newCategory);
      var cacheResult = cache.getCategory('2');
      var ldbResult = await localDatabase.getCategory('2');
      var apiResult = await api.getCategory('2');

      var expectedCategory = {
        'category_id': '2',
        'title': 'New title',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00'
      };

      expect(serviceResponse.statusCode, 200);
      expect(cacheResult, expectedCategory);
      expect(ldbResult.data, expectedCategory);
      expect(apiResult.data, expectedCategory);
    });

    test("Delete category", () async {
      var serviceResponse = await service.deleteCategory('0');

      var cacheResponse = cache.getCategory('0');
      var ldbResponse = await localDatabase.getCategory('0');
      var apiResponse = await api.getCategory('0');

      expect(serviceResponse.statusCode, 200);
      expect(cacheResponse, null);
      expect(ldbResponse.statusCode, 404);
      expect(apiResponse.statusCode, 404);
    });

    tearDown(() async {
      cache.deleteUser();
      await localDatabase.deleteConfig();
      await localDatabase.deleteUser('1');
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteUser('$id');
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
        await api.deleteCategory('$id');
        await api.deleteTask('$id');
      }
    });
  });

  group("Wrong-authenticated user's Category CRUD tests", () {
    Service service = Service(cache, api, localDatabase);

    setUp(() async {
      var localUserData = {
        "email": "email@mail.ru",
        'password': "wrong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      var webUserData = {
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      await localDatabase.putConfig({
        "user_id": '1',
        'theme': 'dart',
        'language': "en_US",
        'notify_about_sign_up': false
      });
      await localDatabase.putUser("1", localUserData);
      await api.addUser('1', webUserData);

      var category0 = {
        'title': 'Delete me',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00'
      };
      var category1 = {
        'title': 'Get me',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00'
      };
      var category2 = {
        'title': 'Update me',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00'
      };

      await localDatabase.putCategory('0', category0);
      await api.addCategory('0', category0);
      await localDatabase.putCategory('1', category1);
      await api.addCategory('1', category1);
      await localDatabase.putCategory('2', category2);
      await api.addCategory('2', category2);

      await service.initialize();
    });

    test("Get category", () async {
      Category result = service.getCategory('1')!;

      Category expectedCategory = Category(
          categoryId: '1',
          userId: '1',
          title: 'Get me',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));
      expect(result, expectedCategory);
    });

    test("Get categories list", () async {
      List<Category> result = service.getCategoriesList();

      Category category0 = Category(
          categoryId: '0',
          userId: '1',
          title: 'Delete me',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));
      Category category1 = Category(
          categoryId: '1',
          userId: '1',
          title: 'Get me',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));
      Category category2 = Category(
          categoryId: '2',
          userId: '1',
          title: 'Update me',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));
      expect(result, [category0, category1, category2]);
    });

    test("Add category", () async {
      Category newCategory = Category(
          categoryId: '3',
          userId: '1',
          title: 'New category',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));

      var serviceResponse = await service.addCategory(newCategory);
      var cacheResult = cache.getCategory('3');
      var ldbResult = await localDatabase.getCategory('3');
      var apiResult = await api.getCategory('3');

      expect(serviceResponse.statusCode, 401);
      expect(cacheResult, null);
      expect(ldbResult.statusCode, 404);
      expect(apiResult.statusCode, 404);
    });

    test("Update category", () async {
      Category newCategory = Category(
          categoryId: '2',
          userId: '1',
          title: 'New title',
          creationDate: DateTime.parse('2022-08-11 13:04:00'));

      var serviceResponse = await service.updateCategory(newCategory);
      var cacheResult = cache.getCategory('2');
      var ldbResult = await localDatabase.getCategory('2');
      var apiResult = await api.getCategory('2');

      var expectedCategory = {
        'category_id': '2',
        'title': 'Update me',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00'
      };
      expect(serviceResponse.statusCode, 401);
      expect(cacheResult, expectedCategory);
      expect(ldbResult.data, expectedCategory);
      expect(apiResult.data, expectedCategory);
    });

    test("Delete category", () async {
      var serviceResponse = await service.deleteCategory('0');

      var cacheResponse = cache.getCategory('0');
      var ldbResponse = await localDatabase.getCategory('0');
      var apiResponse = await api.getCategory('0');

      var expectedCategory = {
        'category_id': '0',
        'title': 'Delete me',
        'user_id': '1',
        'creation_date': '2022-08-11 13:04:00'
      };
      expect(serviceResponse.statusCode, 401);
      expect(cacheResponse, expectedCategory);
      expect(ldbResponse.data, expectedCategory);
      expect(apiResponse.data, expectedCategory);
    });

    tearDown(() async {
      cache.deleteUser();
      await localDatabase.deleteConfig();
      await localDatabase.deleteUser('1');
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteUser('$id');
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
        await api.deleteCategory('$id');
        await api.deleteTask('$id');
      }
    });


  });
}
