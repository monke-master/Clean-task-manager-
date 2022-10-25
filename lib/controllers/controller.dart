import 'dart:io';

import 'package:task_manager_arch/models/configuration.dart';
import 'package:task_manager_arch/models/data_response.dart';

import '../models/user.dart';
import '../service/service.dart';

class Controller {

  late final Service _service;

  Future<void> initialize(Service service) async {
    _service = service;
    Configuration? configuration = await service.getConfiguration();
    if (configuration == null) {
      Configuration startingConfig = Configuration(
          userId: 'guest',
          language: Platform.localeName,
          theme: 'system',
          notifyAboutSignUp: true);
      service.setConfiguration(startingConfig);
    } else if (configuration.userId == 'guest') {
      service.syncFromLocalToCache(configuration.userId);
    } else {
      User? user = await service.getUserFromLocal(configuration.userId);
      if (user != null) {
        DataResponse response = await service.authenticate(user);
        if (response.statusCode == 200) {
          await service.syncFromLocalToCache(configuration.userId);
          await service.checkForSync();
        }
      }
    }
  }
  
}