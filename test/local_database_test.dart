

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localstore/localstore.dart';
import 'package:task_manager_arch/repository/local_database.dart';
import 'package:task_manager_arch/repository/repository_response.dart';

void main() {

  Localstore store = Localstore.instance;
  LocalDatabase database = LocalDatabase();
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();

    database.init();

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

  });

  group("user tests", () {

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
      database.putUser('4', data);
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
      RepositoryResponse response = await database.deleteUser('56789');
      expect(response.statusCode, 200);
    });
  });

  tearDownAll(() async {
    for (int id = 0; id < 5; id++) {
      await store.collection('user').doc('$id').delete();
    }
  });






}