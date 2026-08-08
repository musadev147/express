
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'mock_db_service.dart';

final locator = GetIt.instance;
final appData = locator.get<GetStorage>();

void diSetup() {
  locator.registerSingleton<GetStorage>(GetStorage());
  Get.put(MockDbService());
}

