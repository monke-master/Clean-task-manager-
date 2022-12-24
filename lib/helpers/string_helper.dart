class StringHelper {

  static String getId(String badId) {
    return badId.split("\\")[2];
  }

  static bool isValidEmail(String email) {
    RegExp regExp = RegExp("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9_.+-]+(")
  }

}

