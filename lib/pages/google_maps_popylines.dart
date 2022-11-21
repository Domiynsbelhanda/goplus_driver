import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/screens/checkPage.dart';
import 'package:goplus_driver/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../services/auth.dart';
import '../utils/global_variables.dart';
import '../widget/app_button.dart';

class GoogleMapsPolylines extends StatefulWidget {
  String? uuid;
  GoogleMapsPolylines({Key? key, this.uuid}) : super(key: key);

  @override
  _Poly createState() => _Poly();
}

class _Poly extends State<GoogleMapsPolylines> {

  Set<Marker> markers = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> destinationPolylineCoordinates = [];
  CameraPosition? cam;
  late Size size;

  addDestinationPolyLine(List<LatLng> polylineCoordinates, String ids) {
    PolylineId id = PolylineId(ids);
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepOrange,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
  }

  addPoly(LatLng driver, LatLng depart, LatLng destination) async{
    destinationPolylineCoordinates.clear();
    destinationPolylineCoordinates.add(LatLng(driver.latitude, driver.longitude));
    destinationPolylineCoordinates.add(LatLng(destination.latitude, destination.longitude));
    addDestinationPolyLine(destinationPolylineCoordinates, 'second');
  }

  @override
  @override
  Widget build(BuildContext context) {
    if(widget.uuid == null){
      Navigator.pop(context);
    }
    size = MediaQuery.of(context).size;
    ToastContext().init(context);
    readBitconMarkerPinner();
    return Scaffold(
      body: SizedBox(
          child : StreamBuilder(
              stream: FirebaseFirestore.instance.collection("courses").doc(widget.uuid).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

                if(!snapshot.hasData){
                  return const Text("Chargement en cours...");
                }

                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                markers.clear();

                markers.add(
                    Marker(
                      markerId: const MarkerId('Depart'),
                      position: LatLng(data['depart_latitude'], data['depart_longitude']),
                      infoWindow: const InfoWindow(
                        title: 'Depart',
                        snippet: 'Moi',
                      ),
                      icon: departBitmap!,
                    )
                );

                markers.add(
                    Marker(
                      markerId: const MarkerId('Arrivée'),
                      position: LatLng(data['destination_latitude'], data['destination_longitude']),
                      infoWindow: const InfoWindow(
                        title: 'Arrivée',
                        snippet: 'Moi',
                      ),
                      icon: arriveBitmap!,
                    )
                );

                markers.add(
                    Marker(
                      markerId: const MarkerId('Driver'),
                      position: LatLng(data['driver_latitude'], data['driver_longitude']),
                      infoWindow: const InfoWindow(
                        title: 'Driver',
                        snippet: 'Moi',
                      ),
                      icon: car_android!,
                    )
                );

                cam = CameraPosition(
                    target: LatLng(data['driver_latitude'], data['driver_longitude']),
                    zoom: zoom
                );

                addPoly(
                    LatLng(data['driver_latitude'], data['driver_longitude']),
                    LatLng(data['depart_latitude'], data['depart_longitude']),
                    LatLng(data['destination_latitude'], data['destination_longitude'])
                );

                return Stack(
                  children: [
                    SafeArea(
                        child : GoogleMap(
                          zoomGesturesEnabled: true,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          initialCameraPosition: cam!,
                          markers: markers,
                          polylines: Set<Polyline>.of(polylines.values),
                          compassEnabled: true,
                          onMapCreated: (ctrl){
                            ctrl.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                        target: LatLng(data['driver_latitude'], data['driver_longitude']),
                                        zoom: 17)
                                  //17 is new zoom level
                                )
                            );
                          },
                        )
                    ),

                    Positioned(
                        bottom: 0,
                        right: 16,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: data['status'] == 'end'
                                ? showCourse(data)
                                : showDriver(data)
                        )
                    ),
                  ],
                );
              })
      ),
    );
  }

  Widget showDriver(data){
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: data['status'] == 'confirm' ? MediaQuery.of(context).size.width / 2.1 : MediaQuery.of(context).size.width / 2.1,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppButton(
              color: AppColors.primaryColor,
              name: data['status'] == 'view'
                  ? 'ACCEPTER'
                  : data['status'] == 'confirm' ?
              'DEMARRER COURSE' : data['status'] == 'start' ? 'TERMINER COURSE' : 'COURSE ANNULEE.',
              onTap: (){
                showLoader('Veuillez patienter');
                if(data['status'] == 'view'){
                  FirebaseFirestore.instance.collection('courses').doc(widget.uuid).update({
                    'status': "confirm"
                  }).then((value){
                    FirebaseFirestore.instance.collection('clients').doc('${data['users']}').update({
                    'status': 'confirm',
                    });
                    disableLoader();
                });
              } else if(data['status'] == 'confirm'){
                  DateTime start = DateTime.parse(DateTime.now().toString());
                  var datas = {
                    "key": "ride",
                    "action": "create",
                    "driversid": data['sid_driver'],
                    "clientsid": data['sid_user'],
                    "latinit": data['depart_latitude'],
                    "longinit": data['depart_longitude'],
                    "latend": data['destination_latitude'],
                    "longend": data['destination_longitude'],
                    "ridedate": "${start.day}-${start.month}-${start.year}",
                    "starthour": "${start.hour}:${start.minute}",
                    "type": "1"
                  };

                  Provider.of<Auth>(context, listen: false)
                      .request(data: datas).then((value)
                  {
                    FirebaseFirestore.instance.collection('courses').doc(widget.uuid).update({
                      'status': "start",
                      'rideref': value['rideref'],
                      'value': value.toString(),
                      'start_time': FieldValue.serverTimestamp()
                    }).then((value){
                      FirebaseFirestore.instance.collection('clients').doc('${data['users']}').update({
                        'status': 'start',
                      });
                      disableLoader();
                    });
                  });
                } else if(data['status'] == 'start'){
                  DateTime start = DateTime.parse(data['start_time'].toDate().toString());
                  DateTime end = DateTime.parse(DateTime.now().toString());

                  var price = 0.0;
                  if(data['carType'] == "1"){
                    price = ((end.difference(start).inMinutes / 30) +1) * 10;
                  } else if(data['carType'] == "2") {
                    price = ((end.difference(start).inMinutes / 30) +1) * 15;
                  } else if (data['carType'] == "3"){
                    price = ((end.difference(start).inMinutes / 30) +1) * 14;
                  }

                  var datas = {
                    "key": "ride",
                    "action": "update",
                    "driversid": data['sid_driver'],
                    "clientsid": data['sid_user'],
                    "endhour": "${end.hour}:${end.minute}",
                    "rideref": data['rideref'],
                    "type": "1",
                    "service" : "4",
                    "price": price
                  };

                  Provider.of<Auth>(context, listen: false)
                      .request(data: datas).then((value)
                  {
                    FirebaseFirestore.instance.collection('courses').doc(widget.uuid).update({
                      'status': "end",
                      "endhour": "${end.hour}:${end.minute}",
                      "prix": double.parse((price).toStringAsFixed(2))
                    }).then((value){
                      FirebaseFirestore.instance.collection('clients').doc('${data['users']}').update({
                        'status': 'end',
                      });
                      FirebaseFirestore.instance.collection('drivers').doc('${data['driver']}').update({
                        'online': false,
                        'ride': false,
                        'uuid': null,
                      });
                      disableLoader();
                    });
                  });
                }
            },
            ),

            const SizedBox(height: 8.0),

            data['status'] == "confirm" ? const SizedBox() :
            AppButton(
              color: Colors.black,
              name: data['status'] == 'view' ? 'ANNULER' : 'FERMER',
              onTap: (){
                if(data['status'] == 'view'){
                  FirebaseFirestore.instance.collection('drivers').doc('${data['driver']}').update({
                    'online': true,
                    'ride': false,
                    'uuid': null,
                  });

                  FirebaseFirestore.instance.collection('courses').doc(widget.uuid).update({
                    'status': "cancel"
                  }).then((value){
                    FirebaseFirestore.instance.collection('clients').doc('${data['users']}').update({
                      'status': 'cancel',
                    });

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => CheckPage()
                        ),
                            (Route<dynamic> route) => false
                    );
                  });
                } else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => CheckPage()
                      ),
                          (Route<dynamic> route) => false
                  );
                };
              },
            ),

            const SizedBox(height: 8.0),

            data['status'] == "confirm" ?
            AppButton(
              color: AppColors.primaryColor,
              name: 'APPELER ',
              onTap: ()=>makePhoneCall('+243${data['users']}'),
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget showCourse(data){
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.width / 2.0,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La course vient de prendre fin.',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 30
              ),
            ),

            const SizedBox(height: 8.0,),

            Text(
              'Prix : ${data['prix']}',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 30
              ),
            ),
            const SizedBox(height: 16.0,),
            AppButton(
              color: AppColors.primaryColor,
              name: 'FERMER ',
              onTap: ()=>Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => CheckPage()
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}