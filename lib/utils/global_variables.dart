import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();
FirebaseFirestore firestore = FirebaseFirestore.instance;
String? key;
bool? online;

void storeToken({required String token}) async{
  await storage.write(key: 'token', value: token);
}

void getToken() async{
  key = await storage.read(key: 'token');
}

void deleteToken(String key) async{
  await storage.delete(key: key);
}