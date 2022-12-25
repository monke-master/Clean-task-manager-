class StringHelper {

  static String getId(String badId) {
    return badId.split("\\")[2];
  }

  static bool isValidEmail(String email) {
    RegExp regExp = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');
    return regExp.hasMatch(email);
  }

  static bool containsLetter(String password) {
    RegExp regExp = RegExp(r'^(?=.*[a-zA-Z])');
    return regExp.hasMatch(password);
  }

  static bool isValidPassword(String password) {
    RegExp regExp = RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9*!?@#$%^&()|?<>_.+-]{8,32}$');
    return regExp.hasMatch(password);
  }

}
