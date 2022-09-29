import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();
String? key;

void storeToken({required String token}) async{
  await storage.write(key: 'token', value: token);
}

void getToken() async{
  key = await storage.read(key: 'token');
}