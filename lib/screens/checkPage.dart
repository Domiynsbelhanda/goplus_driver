import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goplus_driver/utils/global_variables.dart';

import 'enter_phone_number_screen.dart';

class CheckPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return keys == null ? PhoneNumberScreen() :
    StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('drivers')
        .doc(keys).collection('courses').doc('courses').snapshots(),
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