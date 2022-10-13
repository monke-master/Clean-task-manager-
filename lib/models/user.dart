class User {

  String id;
  String? email;
  String? password;
  DateTime? registrationDate;

  User({required this.id, required this.email, required this.password,
    required this.registrationDate});

  @override
  int get hashCode => Object.hash(id, email, password, registrationDate);

  @override
  bool operator == (Object other) =>
      other is User &&
      other.id == id &&
      other.email == email &&
      other.password == password &&
      other.registrationDate == registrationDate;




}