import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:goplus_driver/pages/homePage.dart';
import 'package:goplus_driver/screens/checkPage.dart';
import '../screens/signup_screen.dart';
import '../screens/verify_number_screen.dart';
import '../widget/notification_dialog_auth.dart';
import '../widget/notification_loader.dart';
import 'dio.dart';


class Auth extends ChangeNotifier{
  String? _token;

  final storage = new FlutterSecureStorage();

  void login ({required Map creds, required BuildContext context}) async {
    notification_loader(context, (){});

    try {
      Dio.Response response = await dio()!.post('/v1/', data: creds);
      if(response.statusCode == 200){
        var res = jsonDecode(response.data);
        if(res['code'] == "OTP"){
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => VerifyNumberScreen(phone: creds['phone']))
          );
        } else if(res['NOK']){
          notification_dialog_auth(
              context,
              'Vérifiez votre mot de passe',
              Icons.error,
              Colors.red,
              {'label': 'REESAYEZ', "onTap": (){
                Navigator.pop(context);
              }},
              20,
              false);
        } else if (res['KO']){
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SignupScreen())
          );
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

  void register ({required Map cred, required BuildContext context}) async {

    notification_loader(context, (){});

    try {
      Dio.Response response = await dio()!.post('/v1/', data: cred);
      if(response.statusCode == 200){
        var res = jsonDecode(response.data);
        if(res['code'] == "OTP"){
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
          sendOtp(context, cred['phone']).then((value){
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => VerifyNumberScreen(phone: cred['phone']))
            );
          });
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

  Future<String> checkOtp(BuildContext context, var data) async {
    try{
      Dio.Response response = await dio()!.post('/v1/', data: jsonEncode(data));
      Map<String, dynamic> datas = jsonDecode(response.data);
      storeToken(token: data['phone']);

      FirebaseFirestore.instance.collection('drivers').doc(data['phone']).set(data);
      notifyListeners();
      Navigator.pop(context);
      return datas['code'];
    } catch(e){
      return "KO";
    }
  }

  void storeCourse({required Map<String, dynamic> data, required BuildContext context}){
    notification_loader(context, (){});
  }

  void storeToken({required String token}) async{
    this.storage.write(key: 'token', value: token);
    notifyListeners();
  }

  Future<String?> getToken() async{
    return await storage.read(key: 'token');
  }

  void logout() async{
    try {
      Dio.Response response = await dio()!.get('/user/revoke',
          options: Dio.Options(headers: {'Authorization': 'Bearer $_token'})
      );
      cleanUp();
      notifyListeners();
    } catch (e){

    }
  }

  void cleanUp() async {
    await storage.delete(key: 'token');
    notifyListeners();
  }
}