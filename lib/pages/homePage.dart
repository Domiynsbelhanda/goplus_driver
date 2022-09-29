import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/main.dart';
import 'package:goplus_driver/utils/global_variables.dart';
import 'package:goplus_driver/widget/app_button.dart';
import 'package:location/location.dart';
import 'package:blinking_text/blinking_text.dart';
import '../utils/app_colors.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePage();
  }
}

class _HomePage extends State<HomePage>{

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  GoogleMapController? _controller;
  Location _location = Location();
  Set<Marker> markers = Set();
  bool isOnline = false;


  @override
  void initState() {
    getToken();
    firestore.collection('drivers').doc(key).update({
      'online': isOnline,
    });
  }

  void isOnlineCheck(){
    var dataOffline = {
      'state': 'offline',
      'timestamp': FieldValue.serverTimestamp()
    };

    var dataOnline = {
      'state': 'online',
      'timestamp': FieldValue.serverTimestamp()
    };
  }

  void _onMapCreated(GoogleMapController _cntlr)
  {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) async {
      firestore.collection('drivers').doc(key).update({
        'longitude': l.longitude,
        'latitude' : l.latitude
      });
      BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        "assets/images/car_android.png",
      );

      setState(() {
        markers.add(
            Marker( //add start location marker
              markerId: MarkerId('Ma Position'),
              position: LatLng(l.latitude!, l.longitude!), //position of marker
              infoWindow: InfoWindow( //popup info
                title: 'Ma Position',
                snippet: 'Moi',
              ),
              icon: markerbitmap, //Icon for Marker
            )
        );
      });

      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!),zoom: 15),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    CollectionReference users = FirebaseFirestore.instance.collection('drivers');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(key).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: _initialcameraposition),
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: markers,
                  ),

                  Positioned(
                    top: 16.0,
                    left: 0,
                    right: 0,
                    child: BlinkText(
                        'Blink Animation',
                        style: TextStyle(fontSize: 48.0, color: Colors.redAccent),
                        beginColor: Colors.black,
                        endColor: Colors.orange,
                        times: 10,
                        duration: Duration(seconds: 1)
                    ),
                  ),

                  Positioned(
                      bottom: 16.0,
                      left: 0,
                      right: 0,
                      child: AppButton(
                        name: isOnline ? 'DESACTIVER VOTRE POSITION' : 'ACTIVER VOTRE POSITION',
                        color: isOnline ? AppColors.primaryColor : Colors.green,
                        onTap: (){
                          setState(() {
                            isOnline = !isOnline;
                          });
                          if(isOnline){
                            firestore.collection('drivers').doc(key).update({
                              'online': isOnline,
                            });
                          } else {
                            firestore.collection('drivers').doc(key).update({
                              'online': isOnline,
                            });
                          }
                        },
                      )
                  ),

                  Positioned(
                    top: 16.0,
                    left: 16.0,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(48.0)
                      ),
                      child: IconButton(
                        onPressed: (){
                          deleteToken('token');
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => MyApp()
                              ),
                                  (Route<dynamic> route) => false
                          );
                        },
                        icon: Icon(
                          Icons.logout,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
      },
    );
  }
}