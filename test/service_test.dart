import 'package:flutter/cupertino.dart';
import 'package:task_manager_arch/repository/local_database.dart';
import 'package:task_manager_arch/service/service.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_arch/models/task.dart';
import 'package:task_manager_arch/models/user.dart';
import 'package:task_manager_arch/repository/api.dart';
import 'package:task_manager_arch/repository/in_memory_cache.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  InMemoryCache cache = InMemoryCache();
  LocalDatabase localDatabase = LocalDatabase();
  localDatabase.init();
  Api api = Api();
  Service service = Service(cache, api, localDatabase);

  group("Guest user auth test", () {

    setUpAll(() {
      localDatabase.putConfig({
        "user_id": 'guest',
        'theme': 'dart',
        "language": "russian",
        'notif_about_sign_up': false
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

      expect(cache.getCategoriesList().data, expectedCategories);
      expect(cache.getUserTasks().data, expectedTasks);
      expect(cache.getUser().data, expectedUser);
    });

    test("Sign up test", () async {
      await service.initialize();

      String email = "email@mail.ru";
      String password = "password";
      DateTime registrationDate = DateTime.parse("2022-08-11 13:04:00");
      String id = Object.hash(email, password, registrationDate).toString();
      User user = User(id: id, email: email, password: password, registrationDate: registrationDate);
      var signUpResponse = await service.signUp(user);

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

      expect(cache.getCategoriesList().data, expectedCategories);
      expect(cache.getUserTasks().data, expectedTasks);
      expect(cache.getUser().data, expectedUser);
      expect(signUpResponse.statusCode, 200);
    });

    tearDownAll(() async {
      for (int id = 0; id < 15; id++) {
        await localDatabase.deleteUser('$id');
        await localDatabase.deleteCategory('$id');
        await localDatabase.deleteTask('$id');
        await localDatabase.deleteConfig();
        cache.deleteUser();
        cache.deleteTask('$id');
        cache.deleteCategory('$id');
        await api.deleteTask('$id');
        await api.deleteCategory('$id');
        await api.deleteUser('$id');
      }
    });
  });

  group("User with account auth tests", () {
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

      expect(cache.getCategoriesList().data, expectedCategories);
      expect(cache.getUserTasks().data, expectedTasks);
      expect(cache.getUser().data, expectedUser);
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

  group("Crud tests", () {
    setUpAll(() async {
      var userData = {
        "email": "email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };
      await localDatabase.putConfig({
        "user_id": '1',
        'theme': 'dart'});
      await localDatabase.putUser("1", userData);
      await api.addUser('1', userData);
      service.initialize();
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
      cacheRes.data.remove("id");
      var expectedUserData = {
        "email": "new.email@mail.ru",
        'password': "strong_pass",
        'registration_date': '2022-08-11 13:04:00'
      };

      expect(res.statusCode, 200);
      expect(cacheRes.data, expectedUserData);
      expect(localDBRes.data, expectedUserData);
    });


  });
}
