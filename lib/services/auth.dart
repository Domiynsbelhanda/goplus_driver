import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:goplus_driver/screens/checkPage.dart';
import '../screens/signup_screen.dart';
import '../screens/verify_number_screen.dart';
import '../widget/notification_dialog_auth.dart';
import '../widget/notification_loader.dart';
import 'dio.dart';


class Auth extends ChangeNotifier{

  final storage = new FlutterSecureStorage();

  void login ({required Map creds, required BuildContext context}) async {
    notification_loader(context, (){});

    try {
      Dio.Response response = await dio()!.post('/v1/', data: creds);
      if(response.statusCode == 200){
        var res = jsonDecode(response.data);
        if(res['code'] == "OTP"){
          sendOtp(context, creds['phone']).then((value){
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => VerifyNumberScreen(phone: creds['phone']))
            );
          });
        } else if(res['code'] == 'NOK'){
          sendOtp(context, creds['phone']).then((value){
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => VerifyNumberScreen(phone: creds['phone']))
            );
          });
        } else if (res['code'] == 'KO'){
          notification_dialog_auth(
              context,
              'Vous n\'avez pas de compte?',
              Icons.error,
              Colors.red,
              {'label': 'REESAYEZ', "onTap": (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignupScreen())
                );
              }},
              20,
              false);
        }
        else {
          notification_dialog_auth(
              context,
              'Une erreur c\'est produite. ${res['code']}',
              Icons.error,
              Colors.red,
              {'label': 'REESAYEZ', "onTap": (){
                Navigator.pop(context);
                Navigator.pop(context);
              }},
              20,
              false);
        }
      }
    } catch (e){
      notification_dialog_auth(
          context,
          'Une erreur c\'est produite.',
          Icons.error,
          Colors.red,
          {'label': 'FERMER', "onTap": (){
            Navigator.pop(context);
            Navigator.pop(context);
          }},
          20,
          false);
    }
  }

  void register ({required Map<String, dynamic> cred, required BuildContext context}) async {

    notification_loader(context, (){});

    try {
      Dio.Response response = await dio()!.post('/v1/', data: cred);
      if(response.statusCode == 200){
        var res = jsonDecode(response.data);
        if(res['code'] == "OTP"){
          FirebaseFirestore.instance.collection('drivers').doc(cred['phone']).set(cred);
          sendOtp(context, cred['phone']).then((value){
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => VerifyNumberScreen(phone: cred['phone']))
            );
          });
        } else if(res['code'] == "NOK"){
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CheckPage())
          );
        } else if (res['code'] == "KO"){
          notification_dialog_auth(
              context,
              '${res['message']}',
              Icons.error,
              Colors.red,
              {'label': 'REESAYEZ', "onTap": (){
                Navigator.pop(context);
                sendOtp(context, cred['phone']).then((value){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => VerifyNumberScreen(phone: cred['phone']))
                  );
                });
              }},
              20,
              false);
        } else {
          notification_dialog_auth(
              context,
              'Une erreur c\'est produite.',
              Icons.error,
              Colors.red,
              {'label': 'REESAYEZ', "onTap": (){
                Navigator.pop(context);
                Navigator.pop(context);
              }},
              20,
              false);
        }
      }
    } catch (e){
      notification_dialog_auth(
          context,
          'Une erreur c\'est produite.',
          Icons.error,
          Colors.red,
          {'label': 'FERMER', "onTap": (){
            Navigator.pop(context);
            Navigator.pop(context);
          }},
          20,
          false);
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
      Navigator.pop(context);
      return datas['code'];
    } catch(e){
      return "KO";
    }
  }

  Future<Map<String, dynamic>> checkOtp(BuildContext context, var data) async {
    try{
      Dio.Response response = await dio()!.post('/v1/', data: jsonEncode(data));
      Map<String, dynamic> datas = jsonDecode(response.data);
      Navigator.pop(context);
      if(datas['code'] == 'OK'){
        this.storage.write(key: 'sid', value: datas['sid']);
        storeToken(token: data['phone']);
      }
      notifyListeners();
      return datas;
    } catch(e){
      return "KO";
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