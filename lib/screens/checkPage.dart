import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/pages/homePage.dart';
import 'package:goplus_driver/screens/loadingAnimationWidget.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:provider/provider.dart';
import '../pages/google_maps_popylines.dart';
import 'enter_phone_number_screen.dart';

class CheckPage extends StatelessWidget{

  String? cle;
  final Key _mapKey = UniqueKey();

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
          future: Provider.of<Auth>(context, listen: false).getToken(),
          builder: (context, snap) {

            if(!snap.hasData){
              return PhoneNumberScreen();
            }

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('drivers')
                  .doc(snap.data.toString()).collection('courses').doc('courses').snapshots(),
              builder: (context, snapshot){

                if(!snapshot.hasData){
                  return LoadingWidget(message: 'En cours de chargement ...');
                }

                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                if(data != null){
                  return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('drivers')
                          .doc(snap.data.toString()).collection('courses').doc('courses').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

                        if(!snapshot.hasData){
                          return HomePage();
                        }

                        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                        if(data['status'] == 'accept' || data['status'] == 'start'){
                          return GoogleMapsPolylines(
                            destination: LatLng(data['destination_latitude'], data['destination_longitude']),
                            origine: LatLng(data['depart_latitude'], data['depart_longitude']),
                            position: LatLng(data['depart_latitude'], data['depart_longitude']),
                            id: snap.data.toString(),
                            phone: data['user_id'],
                            key: _mapKey,
                          );
                        }

                        return HomePage();
                      }
                  );
                } else {
                  return HomePage();
                }
              },
            );
          }
        );
  }
}