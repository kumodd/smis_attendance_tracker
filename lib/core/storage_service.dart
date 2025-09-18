import 'package:get_storage/get_storage.dart';

class StorageService {
  final _storage = GetStorage();

  Future<void> saveData(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  dynamic readData(String key) {
    return _storage.read(key);
  }

  Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  Future<void> clearStorage() async {
    await _storage.erase();
  }
}