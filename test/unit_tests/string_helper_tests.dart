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

  group("Is valid email test", () {

    test("Kind a normal email", () {
      String email = "pussy.destroyer69@gmail.com";

      bool isValid = StringHelper.isValidEmail(email);

      expect(isValid, true);
    });

    test("Rare email", () {
      String email = "pussy_liker+destroyer@mirea.edu.ru";

      bool isValid = StringHelper.isValidEmail(email);

      expect(isValid, true);
    });

    test("Two emails", () {
      String email = "first.cringe.email@cringe.com second.cringe.email@cringe.com";

      bool isValid = StringHelper.isValidEmail(email);

      expect(isValid, false);
    });

    test("Email without '@'", () {
      String email = "first.cringe.email.cringe.com ";

      bool isValid = StringHelper.isValidEmail(email);

      expect(isValid, false);
    });

    test("Email without domain", () {
      String email = "first.cringe.email@";

      bool isValid = StringHelper.isValidEmail(email);

      expect(isValid, false);
    });

    test("Email with bad domain", () {
      String email = "first.cringe.email@gmail";

      bool isValid = StringHelper.isValidEmail(email);

      expect(isValid, false);
    });
  });

  group("containsLetter tests", () {

    test("With letters", () {
      String password = "123456pdfdsdP";

      bool contains = StringHelper.containsLetter(password);

      expect(contains, true);
    });

    test("With one letter", () {
      String password = "123456p%^&*(390";

      bool contains = StringHelper.containsLetter(password);

      expect(contains, true);
    });

    test("Without letters", () {
      String password = "123456%^&*(390";

      bool contains = StringHelper.containsLetter(password);

      expect(contains, false);
    });
  });

  group("isValidPassword tests", () {

    test("Valid password", () {
      String password = "veryStrongPassword1580!";

      bool isValid = StringHelper.isValidPassword(password);

      expect(isValid, true);
    });

    test("Valid password 2", () {
      String password = "p9*!?@#%^&()|?<>_.+-";

      bool isValid = StringHelper.isValidPassword(password);

      expect(isValid, true);
    });

    test("Password without letters", () {
      String password = "9*!?@#%^&()|?<>_.+-";

      bool isValid = StringHelper.isValidPassword(password);

      expect(isValid, false);
    });

    test("Password's length smaller than 8", () {
      String password = "passwor";

      bool isValid = StringHelper.isValidPassword(password);

      expect(isValid, false);
    });


    test("Password's length bigger than 32", () {
      String password = "passwordpassword167890-2-34095758940-3";

      bool isValid = StringHelper.isValidPassword(password);

      expect(isValid, false);
    });


  });
}