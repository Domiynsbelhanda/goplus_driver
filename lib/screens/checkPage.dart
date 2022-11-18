import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goplus_driver/pages/homePage.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:provider/provider.dart';
import '../utils/global_variables.dart';
import 'enter_phone_number_screen.dart';

class CheckPage extends StatelessWidget{

  String? cle;
  final Key _mapKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: Provider.of<Auth>(context, listen: false).getToken(),
          builder: (context, tokens) {
            if(!tokens.hasData){
              return PhoneNumberScreen();
            }
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('drivers')
                  .doc(tokens.data.toString()).snapshots(),
              builder: (context, snapshot){
                driver_token = tokens.data.toString();
                if(!snapshot.hasData){
                  return const Text('En cours de chargement ...');
                }
                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                return HomePage(
                  token: tokens.data.toString(),
                  data: data,
                );
              },
            );
          }
        );
  }
}