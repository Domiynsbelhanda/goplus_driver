import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

void storeToken({required String token}) async{
  storage.write(key: 'token', value: token);
}

Future<String?> getToken() async{
  return storage.read(key: 'token');
}