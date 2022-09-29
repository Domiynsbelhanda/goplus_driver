import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';
import 'package:taxigo_driver/screens/login.dart';
import 'package:taxigo_driver/globalvariabels.dart';

import '../application.dart';

class ProfileTab extends StatelessWidget {

  String value = langue;
  List<S2Choice<String>> options = [
    S2Choice<String>(value: 'en', title: 'Anglais'),
    S2Choice<String>(value: 'fr', title: 'Français'),
    S2Choice<String>(value: 'ar', title: 'Arabe'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                currentDriverInfo.image),
              radius: 80.0,
            ),

            SizedBox(height: 5.0),

            Text(
                  currentDriverInfo.fullName,
                  style: TextStyle(fontSize: 32.0),
                ),
                Text(
                  currentDriverInfo.email,
                  style: TextStyle(fontSize: 16.0),
                ),

                Text(
                  currentDriverInfo.phone,
                  style: TextStyle(fontSize: 12.0),
                ),

                Text(
                  '${currentDriverInfo.carModel} / ${currentDriverInfo.vehicleNumber} / ${currentDriverInfo.carColor}',
                  style: TextStyle(fontSize: 12.0),
                ),


            SizedBox(height: 20.0),

            SmartSelect<String>.single(
              title: 'Langue',
              value: value,
              choiceItems: options,
              onChange: (state) async{
                value = state.value;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('langue', value);
                applic.onLocaleChanged(new Locale(value,''));
                (context as Element).markNeedsBuild();
              }
            ),

            SizedBox(height: 20.0,),

            RaisedButton(
              onPressed: (){
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);

              },
                child: Container(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.width / 7,
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x29000000),
                      offset: Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child :Text(
                    "Log out",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 15,
                    )
                    )
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
