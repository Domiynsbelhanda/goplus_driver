import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goplus_driver/screens/IntroScreen.dart';

import '../utils/global_variables.dart';

class CheckPage extends StatelessWidget{

  String? cle;

  @override
  Widget build(BuildContext context) {

    cle = keyss!;
    // TODO: implement build
    return cle == null ? IntroScreen() :
    StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('drivers')
        .doc(cle!).collection('courses').doc('courses').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if(!snapshot.hasData){
        return const Text('Wait');
        }

        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

        return Text('');
        }
    );
  }
}