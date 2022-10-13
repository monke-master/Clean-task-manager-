import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:localstore/localstore.dart';
import 'package:task_manager_arch/models/data_response.dart';
import 'package:task_manager_arch/repository/local_database.dart';
import 'package:task_manager_arch/service/service.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_arch/models/task.dart';
import 'package:task_manager_arch/models/user.dart';
import 'package:task_manager_arch/repository/api.dart';
import 'package:task_manager_arch/repository/in_memory_cache.dart';

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
          'completed': '0'
        }
      };
      var expectedCategories = {
        '1': {
          "user_id": "guest",
          "title": "Get me ",
          "creation_date": '2022-08-11 13:04:00'
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
      await localDatabase.deleteConfig();
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
        await api.deleteUser('$id');
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
      User oldUser = User(
          id: '1',
          email: "email@mail.ru",
          password: "strong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));
      User newUser = User(
          id: '1',
          email: "new.email@mail.ru",
          password: "strong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));

      var res = await service.updateUser(oldUser, newUser);
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
      User oldUser = User(
          id: '1',
          email: "email@mail.ru",
          password: "strong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));
      User newUser = User(
          id: '1',
          email: "email@mail.ru",
          password: "mega_strong_password",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));

      var res = await service.updateUser(oldUser, newUser);
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
      User user = User(
          id: '1',
          email: "email@mail.ru",
          password: "strong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));
      var deleteResponse = await service.deleteUser(user);

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
      await localDatabase.deleteUser('guest');
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
        await api.deleteTask('$id');
        await api.deleteCategory('$id');
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
      User oldUser = User(
          id: '1',
          email: "email@mail.ru",
          password: "wrong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));
      User newUser = User(
          id: '1',
          email: "email@mail.ru",
          password: "strong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));

      var apiResponse = await service.updateUser(oldUser, newUser);
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
      User oldUser = User(
          id: '1',
          email: "email@mail.ru",
          password: "wrong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));
      User newUser = User(
          id: '1',
          email: "new_email@mail.ru",
          password: "wrong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));

      var apiResponse = await service.updateUser(oldUser, newUser);
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
      User user = User(
          id: '1',
          email: "email@mail.ru",
          password: "wrong_pass",
          registrationDate: DateTime.parse('2022-08-11 13:04:00'));

      var response = await service.deleteUser(user);
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
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteUser('$id');
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
        await api.deleteTask('$id');
        await api.deleteCategory('$id');
      }
    });
  });

  group("Guest user CRUD tests", () {
    Service service = Service(cache, api, localDatabase);

    setUp(() async {
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
      User user = User(
          id: 'guest',
          email: null,
          password: null,
          registrationDate: null);

      var response = await service.deleteUser(user);
      var ldbResponse = await localDatabase.getUser('guest');

      var expectedUserData = {
        'id': 'guest',
      };
      expect(response.statusCode, 200);
      expect(cache.getUser(), expectedUserData);
      expect(ldbResponse.data, expectedUserData);
    });

    tearDown(() async {
      cache.deleteUser();
      await localDatabase.deleteConfig();
      await localDatabase.deleteUser('guest');
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteUser('$id');
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
        await api.deleteTask('$id');
        await api.deleteCategory('$id');
      }
    });
  });

  group("Category CRUD tests", () {
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


  });
}
