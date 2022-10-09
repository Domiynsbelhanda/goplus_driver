
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:goplus_driver/widget/app_button.dart';
import 'package:goplus_driver/widget/notification_dialog.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../widget/backButton.dart';
import '../widget/notification_loader.dart';

class GoogleMapsPolylines extends StatefulWidget {
  LatLng origine;
  LatLng destination;
  LatLng? position;
  String id;
  String? phone;

  GoogleMapsPolylines({required Key key, this.phone, required this.id, required this.origine, required this.destination, this.position}) : super(key: key);

  @override
  _Poly createState() => _Poly();
}

class _Poly extends State<GoogleMapsPolylines> {

  GoogleMapController? _controller;
  Location _location = Location();
  CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(19.0759837, 72.8776559),
    zoom: 14,
  );
  late LatLng position;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};

  // list of locations to display polylines
  late List<LatLng> latLen;

  void _onMapCreated(_cntlr)
  {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) async {
      position = LatLng(l.latitude!, l.longitude!);
      FirebaseFirestore.instance.collection('drivers').doc(widget.id).update({
        'longitude': l.longitude,
        'latitude' : l.latitude
      });
      BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        "assets/images/car_android.png",
      );

      BitmapDescriptor departBitmap = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        "assets/images/drapeau-a-damier.png",
      );

      BitmapDescriptor arriveBitmap = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        "assets/images/drapeau.png",
      );

      setState(() {
        _markers.clear();
        _markers.add(
          // added markers
            Marker(
                markerId: MarkerId('${latLen[1].longitude}'),
                position: latLen[1],
                infoWindow: InfoWindow(
                  title: '${1 + 1} ${1 == 0 ? 'Votre Position' : 1 == 1 ? 'Lieu de ramassage' : 1 == 2 ? 'Destination du client' : ''}',
                  snippet: '',
                ),
              icon: departBitmap
            )
        );
        _markers.add(
          // added markers
            Marker(
                markerId: MarkerId('${latLen[2].longitude}'),
                position: latLen[2],
                infoWindow: InfoWindow(
                  title: '${2 + 1} ${2 == 0 ? 'Votre Position' : 2 == 1 ? 'Lieu de ramassage' : 2 == 2 ? 'Destination du client' : ''}',
                  snippet: '',
                ),
              icon: arriveBitmap
            )
        );
        _markers.add(
            Marker( //add start location marker
              markerId: MarkerId('Ma Position'),
              position: LatLng(l.latitude!, l.longitude!),
              infoWindow: InfoWindow(
                title: 'Ma Position',
                snippet: 'Moi',
              ),
              icon: markerbitmap,
            )
        );

        position = LatLng(l.latitude!, l.longitude!);
      });


      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!),zoom: 15),
        ),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // if(widget.id != null){
    //   FirebaseFirestore.instance.collection('drivers').doc(widget.id!).collection('courses')
    //       .doc('courses')
    //       .update({
    //     'status': 'accept',
    //   });
    // }

    latLen = [
      widget.position!,
      widget.origine,
      widget.destination,
    ];

    _kGoogle = CameraPosition(
      target: widget.position!,
      zoom: 14,
    );

    // declared for loop for various locations
    for(int i=0; i<latLen.length; i++){
      _polyline.add(
          Polyline(
            polylineId: PolylineId('1'),
            points: latLen,
            color: Colors.green,
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: GoogleMap(
            initialCameraPosition: _kGoogle,
            mapType: MapType.normal,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            polylines: _polyline,
            onMapCreated: _onMapCreated,
          ),
        ),

        widget.phone != null ? Positioned(
          right: 16,
          top: 16,
          child: CloseButtons(context),
        ) : SizedBox(),

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
        ) : SizedBox(),

        widget.phone != null ? Positioned(
            bottom: 32,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('drivers')
              .doc(widget.id).collection('courses').doc('courses').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

              if(!snapshot.hasData){
                return Text('Vérifiez votre connexion');
              }

              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                children: [
                  AppButton(
                    onTap: (){
                      if(data['status'] == 'start'){
                        DateTime start = DateTime.parse(data['start_time'].toDate().toString());
                        DateTime end = DateTime.parse(DateTime.now().toString());
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
                          "endhour": "${end.hour}:${end.minute}",
                          "price": (end.difference(start).inHours +1) * 5
                        };

                        Provider.of<Auth>(context, listen: false)
                            .storeCourse(data: datas, context: context).then((value){
                           if(value['code'] == 'OK'){
                             notification_dialog(
                                 context,
                                     (){
                                   FirebaseFirestore.instance.collection('drivers').doc(widget.id).collection('courses')
                                       .doc('courses')
                                       .update({
                                     'status': 'end',
                                     'end_time': FieldValue.serverTimestamp(),
                                     'duree': end.difference(start).inHours + 1,
                                     'prix': (end.difference(start).inHours +1) * 5
                                   });
                                 },
                                 'Course Terminée :\n Réf : ${value['rideref']}\nDébut : ${start}\nFin : ${end},\n Durée : ${end.difference(start)},\n Prix : ${(end.difference(start).inHours +1) * 5}\$',
                                 Icons.drive_eta,
                                 Colors.green,
                                 15,
                                 false
                             );
                           } else {
                             notification_dialog(
                                 context,
                                     (){
                                 },
                                 'Course Terminée :\n Error : ${value['code']}\nDébut : ${start}\nFin : ${end},\n Durée : ${end.difference(start)},\n Prix : ${(end.difference(start).inHours +1) * 5}\$',
                                 Icons.drive_eta,
                                 Colors.green,
                                 15,
                                 false
                             );
                           }
                        });
                      } else {
                        FirebaseFirestore.instance.collection('drivers').doc(widget.id).collection('courses')
                            .doc('courses')
                            .update({
                          'status': 'start',
                          'start_time': FieldValue.serverTimestamp()
                        });
                      }
                    },
                    name: data['status'] == 'start' ? 'TERMINER LA COURSE' : 'DEMARRER LA COURSE',
                    color: Colors.yellow,
                  ),
                ],
              );
            })
        ) : SizedBox(),
      ],
    );
  }
}