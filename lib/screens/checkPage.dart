import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/screens/IntroScreen.dart';

import '../pages/google_maps_popylines.dart';
import '../utils/global_variables.dart';

class CheckPage extends StatelessWidget{

  String? cle;
  final Key _mapKey = UniqueKey();

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
          return IntroScreen();
        }

        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

        if(data['status'] == 'accept' || data['status'] == 'start'){
          return GoogleMapsPolylines(
            destination: LatLng(data['destination_latitude'], data['destination_longitude']),
            origine: LatLng(data['depart_latitude'], data['depart_longitude']),
            position: LatLng(data['depart_latitude'], data['depart_longitude']),
            id: cle!,
            phone: data['user_id'],
            key: _mapKey,
          );
        }

        return IntroScreen();
        }
    );
  }
}