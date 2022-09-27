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
        'theme': 'dart'});
      localDatabase.putUser("guest", {});
      localDatabase.putCategory('1', {
        "user_id": "1",
        "title": "Get me ",
        "creation_date": '2022-08-11 13:04:00'
      });
      localDatabase.putCategory('1', {
        'user_id': '1',
        'title': 'Get me',
        'creation_date': '2022-08-11 13:04:00',
        'completed': 0
      });
    });

    test("Init test", () async {
      await service.initialize();

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
          "title": "Get me ",
          "creation_date": '2022-08-11 13:04:00'
        }
      };

      expect(cache.getCategoriesList(), expectedCategories);
      expect(cache.getUserTasks(), expectedTasks);
    });
  });
}
