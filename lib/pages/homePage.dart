import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/main.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:goplus_driver/widget/app_button.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import 'google_maps_popylines.dart';

class HomePage extends StatefulWidget{
  String token;
  Map<String, dynamic> data;
  HomePage({Key? key, required this.token, required this.data}) : super(key: key);

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
  Map<String, dynamic>? datas;
  LatLng? position;
  bool ride = false;
  int nb = 0;
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if(widget.data['ride'] != null){
      if(widget.data['ride']){
        if(widget.data['uuid'] != null){
          setState(() {
            ride = true;
          });
          Provider.of<Auth>(context, listen: false).getSid()
              .then((sid){
            FirebaseFirestore.instance.collection('courses')
                .doc(widget.data['uuid']).update(
                {
                  'sid_driver': sid
                }
            );
          });
        } else {
          setState(() {
            ride = false;
          });
        }
      } else {
        ride = false;
      }
    } else {
      setState(() {
        ride = false;
      });
    }

    if(widget.data['latitude'] != null){
      _initialcameraposition = LatLng(widget.data['latitude'], widget.data['longitude']);
    }

    return Scaffold(
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: _initialcameraposition,
                      zoom: 15
                  ),
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller){
                    _controller = controller;
                    _location.onLocationChanged.listen((l) async {
                      _initialcameraposition = LatLng(l.latitude!, l.longitude!);
                      FirebaseFirestore.instance.collection('drivers').doc(widget.token.toString()).update({
                        'longitude': l.longitude,
                        'latitude' : l.latitude
                      });
                      BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
                        const ImageConfiguration(),
                        "assets/images/car_android.png",
                      );

                      setState(() {
                        markers.add(
                            Marker( //add start location marker
                              markerId: const MarkerId('Ma Position'),
                              position: LatLng(l.latitude!, l.longitude!), //position of marker
                              infoWindow: const InfoWindow( //popup info
                                title: 'Ma Position',
                                snippet: 'Moi',
                              ),
                              icon: markerbitmap, //Icon for Marker
                            )
                        );

                        position = LatLng(l.latitude!, l.longitude!);

                        _controller!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: LatLng(l.latitude!, l.longitude!),zoom: 15),
                          ),
                        );
                      });

                    });
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: markers,
                ),

                ride ? const SizedBox() : Positioned(
                    bottom: 16.0,
                    left: 0,
                    right: 0,
                    child: AppButton(
                      name: isOnline ? 'DESACTIVER VOTRE POSITION' : 'ACTIVER VOTRE POSITION',
                      color: isOnline ? AppColors.primaryColor : Colors.black,
                      onTap: (){
                        setState(() {
                          isOnline = !isOnline;
                        });
                        if(isOnline){
                          FirebaseFirestore.instance.collection('drivers').doc(widget.token.toString()).update({
                            'online': isOnline,
                          });
                        } else {
                          FirebaseFirestore.instance.collection('drivers').doc(widget.token.toString()).update({
                            'online': isOnline,
                          });
                        }
                      },
                    )
                ),

                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(48.0)
                    ),
                    child: IconButton(
                      onPressed: (){
                        Provider.of<Auth>(context, listen: false).cleanUp();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => MyApp()
                            ),
                                (Route<dynamic> route) => false
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                      ),
                    ),
                  ),
                ),

                ride ?
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white
                      ),
                      width: size.width / 1,
                      height: size.width /1.3,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection("courses").doc(widget.data['uuid']).snapshots(),
                        builder: (context, courseSnapshot) {

                          if(courseSnapshot.hasData){
                            var coursesdata = courseSnapshot.data! as DocumentSnapshot;
                            Map<String, dynamic> courses = coursesdata.data() as Map<String, dynamic>;
                            return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children : [
                                      const Text(
                                        'En attente de la réponse',
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),

                                      TimerCountdown(
                                        secondsDescription: 'Secondes',
                                        minutesDescription: 'Minutes',
                                        timeTextStyle: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold
                                        ),
                                        format: CountDownTimerFormat.minutesSeconds,
                                        endTime: DateTime.now().add(
                                          const Duration(
                                            minutes: 5,
                                            seconds: 30,
                                          ),
                                        ),
                                        onEnd: () {
                                          FirebaseFirestore.instance.collection('courses').doc(widget.data['uuid']).update({
                                            'status': "cancel"
                                          }).then((value){
                                            FirebaseFirestore.instance.collection('clients').doc('${courses['users']}').update({
                                              'status': 'cancel',
                                            });
                                            FirebaseFirestore.instance.collection('drivers').doc(widget.token).update({
                                              'online': true,
                                              'ride': false,
                                              'uuid': null,
                                            });
                                          });
                                          setState(() {
                                            ride = false;
                                          });
                                        },
                                      ),

                                      const SizedBox(height: 16.0,),

                                      AppButton(
                                        name: "Voir",
                                        color: Colors.black,
                                        onTap: (){
                                          if(widget.data['status'] == 'cancel'){

                                          } else {
                                            FirebaseFirestore.instance.collection('courses').doc(widget.data['uuid']).update({
                                              'status': "view",
                                              'driver': widget.token,
                                              'driver_latitude': widget.data['latitude'],
                                              'driver_longitude': widget.data['longitude']
                                            }).then(
                                                    (value){
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (BuildContext context) =>
                                                            GoogleMapsPolylines(
                                                                uuid: widget.data['uuid']
                                                            )
                                                    ),
                                                  );
                                                }
                                            );
                                          }
                                        },
                                      ),
                                    ]
                                )
                            );
                          }

                          return const Text('');
                        }
                      ),
                    ),
                  ),
                ) : const SizedBox()
              ],
            ),
          ),
        );
  }
}