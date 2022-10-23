
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/pages/homePage.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:goplus_driver/widget/app_button.dart';
import 'package:goplus_driver/widget/notification_dialog.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../screens/loadingAnimationWidget.dart';
import '../utils/global_variables.dart';
import '../widget/backButton.dart';

class GoogleMapsPolylines extends StatefulWidget {
  LatLng origine;
  LatLng destination;
  String id;
  String? phone;

  GoogleMapsPolylines({required Key key, this.phone,
    required this.id, required this.origine, required this.destination}) : super(key: key);

  @override
  _Poly createState() => _Poly();
}

class _Poly extends State<GoogleMapsPolylines> {

  GoogleMapController? _controller;
  Location _location = Location();
  late LatLng position;
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {

    CollectionReference users = FirebaseFirestore.instance.collection('drivers');

    return Stack(
      children: [
        SafeArea(
          child: FutureBuilder<List<BitmapDescriptor>>(
            future : bitmapicon(),
            builder: (context, icons) {
              return FutureBuilder<DocumentSnapshot>(
                future: users.doc(widget.id).get(),
                builder: (context, driverInfo) {

                  if(!driverInfo.hasData){
                    return LoadingWidget(message: 'Chargement en cours...',);
                  }

                  Map<String, dynamic> data = driverInfo.data!.data() as Map<String, dynamic>;

                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(data['latitude'], data['longitude']),
                      zoom: 15,
                    ),
                    mapType: MapType.normal,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    onMapCreated: (controller){
                      _controller = controller;
                      _location.onLocationChanged.listen((l) async {
                        position = LatLng(l.latitude!, l.longitude!);
                        FirebaseFirestore.instance.collection('drivers').doc(widget.id).update({
                          'longitude': l.longitude,
                          'latitude' : l.latitude
                        });

                        setState(() {
                          _markers.clear();
                          _markers.add(
                            // added markers
                              Marker(
                                  markerId: const MarkerId('Votre position'),
                                  position: position,
                                  infoWindow: const InfoWindow(
                                    title: 'Ma position',
                                    snippet: '',
                                  ),
                                  icon: icons.data![0]
                              )
                          );
                          _markers.add(
                            // added markers
                              Marker(
                                  markerId: const MarkerId('Lieu de départ'),
                                  position: widget.origine,
                                  infoWindow: const InfoWindow(
                                    title: 'Lieu de départ',
                                    snippet: '',
                                  ),
                                  icon: icons.data![1]
                              )
                          );
                          _markers.add(
                              Marker( //add start location marker
                                markerId: const MarkerId('Lieu \'arrivée'),
                                position: widget.destination,
                                infoWindow: const InfoWindow(
                                  title: 'Lieu de destination',
                                  snippet: '',
                                ),
                                icon: icons.data![2],
                              )
                          );

                          position = LatLng(l.latitude!, l.longitude!);
                        });


                        _controller!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target: LatLng(l.latitude!, l.longitude!),
                              zoom: 15
                            ),
                          ),
                        );
                      });
                    },
                  );
                }
              );
            }
          ),
        ),

        widget.phone != null ? Positioned(
          right: 16,
          top: 80,
          child: CloseButtons(context),
        ) : const SizedBox(),

        widget.phone != null ? Positioned(
            top: 32,
            left: 16,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              decoration: const BoxDecoration(
                  color: Colors.white
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                        Icons.call
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                        '+243${widget.phone}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black
                      ),
                    ),
                  ],
                ),
              ),
            )
        ) : const SizedBox(),

        widget.phone != null ? Positioned(
            bottom: 32,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('drivers')
              .doc(widget.id).collection('courses').doc('courses').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

              if(!snapshot.hasData){
                return LoadingWidget(message: "Chargement en cours...");
              }

              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                children: [
                  AppButton(
                    onTap: (){
                      if((data['status'] == 'accept')){

                        Map<String, dynamic> datas;
                        DateTime start = DateTime.parse(DateTime.now().toString());

                        if(data['airport']){
                          datas = {
                            "key": "ride",
                            "action": "create",
                            "driversid": data['sid_driver'],
                            "clientsid": data['sid_user'],
                            "latinit": data['depart_latitude'],
                            "longinit": data['depart_longitude'],
                            "ridedate": "${start.day}-${start.month}-${start.year}",
                            "starthour": "${start.hour}:${start.minute}",
                            "type": 2
                          };
                        } else {
                          datas = {
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
                        }

                        Provider.of<Auth>(context, listen: false)
                            .storeCourse(data: datas, context: context).then((value)
                        {
                          FirebaseFirestore.instance.collection('drivers').doc(widget.id).collection('courses')
                              .doc('courses')
                              .update({
                            'status': 'start',
                            'rideref': value['rideref'],
                            'start_time': FieldValue.serverTimestamp()
                          });
                        });
                      } else {

                        Map<String, dynamic> datas;
                        DateTime start = DateTime.parse(data['start_time'].toDate().toString());
                        DateTime end = DateTime.parse(DateTime.now().toString());

                        var price = 0.0;
                        if(!data['airport']){
                          if(data['carType'] == "1"){
                            price = ((end.difference(start).inMinutes / 30) +1) * 10;
                          } else if(data['carType'] == "2") {
                            price = ((end.difference(start).inMinutes / 30) +1) * 12;
                          } else if (data['carType'] == "3"){
                            price = ((end.difference(start).inMinutes / 30) +1) * 14;
                          }
                        } else {
                          if(data['carType'] == "1"){
                            price = 40;
                          } else if(data['carType'] == "2") {
                            price = 55;
                          } else if (data['carType'] == "3"){
                            price = 95;
                          }
                        }

                        datas = {
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
                            .storeCourse(data: datas, context: context).then((value)
                        {
                          if(value['code'] == "OK"){
                            notification_dialog(
                                context,
                                    (){
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => HomePage()
                                      ),
                                          (route) => false);
                                  FirebaseFirestore.instance.collection('drivers').doc(widget.id).collection('courses')
                                      .doc('courses')
                                      .update({
                                    'status': 'end',
                                    'end_time': FieldValue.serverTimestamp(),
                                    'duree': (end.difference(start).inMinutes),
                                    'prix': (end.difference(start).inMinutes) * 5
                                  });
                                },
                                'Course Terminée :\n Réf : ${datas['rideref']}\nDébut : $start\nFin : $end,\n Durée : ${end.difference(start)},\n Prix : $price\$',
                                Icons.drive_eta,
                                Colors.yellow,
                                15,
                                false
                            );
                          } else {
                            notification_dialog(
                                context,
                                    (){
                                  Navigator.pop(context);
                                },
                                "Une erreur s'est produite, essayez de terminer la course.",
                                Icons.drive_eta,
                                Colors.black,
                                15,
                                false
                            );
                          }
                        });
                      }
                    },
                    name: data['status'] == 'start' ? 'TERMINER LA COURSE' : 'DEMARRER LA COURSE',
                    color: Colors.yellow,
                  ),
                ],
              );
            })
        ) : const SizedBox(),
      ],
    );
  }
}