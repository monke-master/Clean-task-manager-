import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_arch/repository/api.dart';

void main() {
  Api api = Api();

  group("User data test", () {
    test('Add user', () async {
      Map<String, dynamic> data = {
        'id': '1',
        'email': 'get.me@gmail.com',
        'password': 'password',
        'registration_date': '2022-08-11 13:04:00'};
      int response = await api.addUser(data);
      expect(response, 200);
    });
  });
}