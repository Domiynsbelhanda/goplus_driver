import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as Dio;
import 'dio.dart';

class Auth extends ChangeNotifier{

  void sendOtp(BuildContext context, String data) async {
    try{
      Dio.Response response = await dio()!.post('/v1/', data: jsonEncode({'phone': data}));
      Map<String, dynamic> dats = jsonDecode(response.data);

      notifyListeners();
    } catch(e){
      print('Paille ${e}');
    }
  }
}