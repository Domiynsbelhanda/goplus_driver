import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:goplus_driver/widget/notification_dialog.dart';
import '../screens/verify_number_screen.dart';
import 'dio.dart';

class Auth extends ChangeNotifier{

  void sendOtp(BuildContext context, var data) async {
    try{
      Dio.Response response = await dio()!.post('', data: jsonEncode(data));
      Map<String, dynamic> datas = jsonDecode(response.data);

      if(datas['code'] == 'OK'){
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyNumberScreen(
                phone: data['phone'],
              ),
            ));
      } else {
        print('${response.statusCode} ca ne marche pas');
      }
      notifyListeners();
    } catch(e){
      notification_dialog(
          context,
          (){},
          'Erreur, veuillez recommencez. $e',
          Icons.error_outline_outlined,
          Colors.red,
          18,
          false
      );
    }
  }
}