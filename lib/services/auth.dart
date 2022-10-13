import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dio.dart';


class Auth extends ChangeNotifier{

  final storage = new FlutterSecureStorage();

  Future<Map<String, dynamic>> login ({required Map creds, required BuildContext context}) async {

    try {
      Dio.Response response = await dio()!.post('/v1/', data: creds);
      Map<String, dynamic> res = jsonDecode(response.data);
      if(response.statusCode == 200){
        return res;
      } else {
        return {
          'code': "NULL"
        };
      }
    } catch (e){
      return {
        'code': "ERROR",
        'error': e
      };
    }
  }

  Future<Map<String, dynamic>> register ({required Map<String, dynamic> cred, required BuildContext context}) async {

    try {
      Dio.Response response = await dio()!.post('/v1/', data: cred);
      Map<String, dynamic> res = jsonDecode(response.data);
      if(response.statusCode == 200){
        return res;
      } else {
        return {
          'code': "NULL"
        };
      }
    } catch (e){
      return {
        'code': "ERROR",
        'error': e
      };
    }
  }

  Future<String> sendOtp(BuildContext context, String phone) async {
    try{
      var data = {
        "key": "otp",
        "phone": phone
      };
      Dio.Response response = await dio()!.post('/v1/', data: jsonEncode(data));
      Map<String, dynamic> datas = jsonDecode(response.data);
      notifyListeners();
      return datas['code'];
    } catch(e){
      return "KO";
    }
  }

  Future<Map<String, dynamic>> checkOtp(BuildContext context, var data) async {
    try{
      Dio.Response response = await dio()!.post('/v1/', data: jsonEncode(data));
      Map<String, dynamic> datas = jsonDecode(response.data);
      if(datas['code'] == 'OK'){
        this.storage.write(key: 'sid', value: datas['sid']);
        storeToken(token: data['phone']);
      }
      notifyListeners();
      return datas;
    } catch(e){
      return {
        'code': "KO"
      };
    }
  }

  Future<Map<String, dynamic>>
  storeCourse({required Map<String, dynamic> data, required BuildContext context}) async{
    try{
      Dio.Response response = await dio()!.post('/v1/', data: jsonEncode(data));
      Map<String, dynamic> datas = jsonDecode(response.data);

      var validation = {
        "key": "ride",
        "action": "update",
        "driversid": data['sid_driver'],
        "rideref": datas['rideref']
      };
      await dio()!.post('/v1/', data: jsonEncode(validation));

      notifyListeners();
      return datas;
    } catch(e){
      return {'code': 'KO'};
    }
  }

  void storeToken({required String token}) async{
    this.storage.write(key: 'token', value: token);
    notifyListeners();
  }

  Future<String?> getToken() async{
    return await storage.read(key: 'token');
  }

  Future<String?> getSid() async{
    return await storage.read(key: 'sid');
  }

  void cleanUp() async {
    await storage.delete(key: 'token');
    notifyListeners();
  }
}