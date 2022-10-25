import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_arch/helpers/string_helper.dart';

void main() {

  group("Get id test", () {

    test("User id", () {
      String res = StringHelper.getId("\\users\\1234");
      expect(res, '1234');
    });

    test("Category id", () {
      String res = StringHelper.getId("\\categories\\qwert12323");
      expect(res, 'qwert12323');
    });

    test("Task id", () {
      String res = StringHelper.getId("\\tasks\\1");
      expect(res, '1');
    });

    test("Error id", () {
      String res = StringHelper.getId("\\errors\\1");
      expect(res, '1');
    });


  });
}