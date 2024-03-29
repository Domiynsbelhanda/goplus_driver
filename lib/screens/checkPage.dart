import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goplus_driver/pages/homePage.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:provider/provider.dart';
import '../utils/global_variables.dart';
import 'enter_phone_number_screen.dart';

class CheckPage extends StatelessWidget{

  CheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: Provider.of<Auth>(context, listen: false).getToken(),
          builder: (context, tokens) {
            if(tokens.hasData){
              return FutureBuilder(
                future: Provider.of<Auth>(context, listen: false).getSid(),
                builder: (context, sidSnap){
                  if(sidSnap.hasData){
                    driver_sid = sidSnap.data.toString();
                    return FutureBuilder(
                      future: Provider.of<Auth>(context, listen: false).request(data: {
                        'key': 'sid',
                        'action': 'sid',
                        'sid': sidSnap.data.toString(),
                        'level': '4'
                      }),
                      builder: (context, checkSidSnap) {
                        if(checkSidSnap.hasData){
                          Map datas = checkSidSnap.data as Map;
                          if(!(datas['code'] == 'OK')){
                            return PhoneNumberScreen();
                          }
                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('drivers')
                                .doc(tokens.data.toString()).snapshots(),
                            builder: (context, snapshot){
                              if(!snapshot.hasData){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16.0,),
                                    Center(child: Text('En cours de chargement ...')),
                                  ],
                                );
                              }
                              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                              driver_token = tokens.data.toString();
                              driver_data = data;
                              return HomePage();
                            },
                          );
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(height: 16.0,),
                            Center(child: Text('En cours de chargement ...')),
                          ],
                        );
                      }
                    );
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16.0,),
                      Center(child: Text('En cours de chargement ...')),
                    ],
                  );
                },
              );
            }

            if(!tokens.hasData){
              return PhoneNumberScreen();
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16.0,),
                Center(child: Text('En cours de chargement ...')),
              ],
            );
          }
        );
  }
}