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
  Service service = Service(cache, Api(), localDatabase);

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
        'completed': 0
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
          'completed': 0
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
      await service.signUp(user);

      var expectedUser = {
        "id": id,
        'password': password,
        'email': email,
        'registration_date': registrationDate
      };
      var expectedTasks = {
        '1': {
          'user_id': id,
          'title': 'Get me',
          'creation_date': '2022-08-11 13:04:00',
          'completed': 0
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
      }
    });
  });

  group("User with account", () {
    setUpAll(() {
      var userData = {
        "email": "email@mail.ru",
        'password': "strong_pass",
        'creation_date': '2022-08-11 13:04:00'
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
        'completed': 0
      });
    });

    test("Init", () async {
      await service.initialize();

      var expectedUser = {
        "id": "1",
        "email": "email@mail.ru",
        'password': "strong_pass",
        'creation_date': '2022-08-11 13:04:00'
      };
      var expectedTasks = {
        '1': {
          'user_id': '1',
          'title': 'Get me',
          'creation_date': '2022-08-11 13:04:00',
          'completed': 0
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
}
