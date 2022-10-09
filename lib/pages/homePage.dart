import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/main.dart';
import 'package:goplus_driver/screens/loadingAnimationWidget.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:goplus_driver/utils/global_variables.dart';
import 'package:goplus_driver/widget/app_button.dart';
import 'package:goplus_driver/widget/progresso_dialog.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';

class HomePage extends StatefulWidget{
  String? phone;
  HomePage({Key? key, this.phone}) : super(key: key);

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


  @override
  void initState() {
    getToken();
    if(widget.phone != null){
      keyss = widget.phone;
    }
    firestore.collection('drivers').doc(keyss).update({
      'online': isOnline,
    });
  }

  void _onMapCreated(GoogleMapController _cntlr)
  {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) async {
      _initialcameraposition = LatLng(l.latitude!, l.longitude!);
      firestore.collection('drivers').doc(keyss).update({
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

        position = LatLng(l.latitude!, l.longitude!);

        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude!, l.longitude!),zoom: 15),
          ),
        );
      });

    });
  }

  int nb = 0;

  @override
  Widget build(BuildContext context) {

    CollectionReference users = FirebaseFirestore.instance.collection('drivers');

    return Scaffold(
          body: FutureBuilder(
            future: Provider.of<Auth>(context, listen: false).getToken(),
            builder: (context, snap) {

              if(!snap.hasData){
                return LoadingWidget();
              }

              return StreamBuilder<DocumentSnapshot>(
              stream: users.doc(snap.data.toString()).snapshots(),
              builder:
                (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if(!snapshot.hasData){
                  return LoadingWidget();
                }

                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                if(data['ride'] != null){
                  if(data['ride']){
                    if(!data['ride_view'] && nb == 0){
                      FirebaseFirestore.instance.collection('drivers').doc(keyss).update({
                        'ride': false,
                        'ride_view': false
                      });
                      nb++;
                      progresso_dialog(context, keyss!, position!);
                    }
                  }

                  if(!data['ride']){
                    nb = 0;
                  }
                }

                if(data['latitude'] != null){
                  _initialcameraposition = LatLng(data['latitude'], data['longitude']);
                }

                return SizedBox(
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
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        markers: markers,
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
                                firestore.collection('drivers').doc(keyss).update({
                                  'online': isOnline,
                                });
                              } else {
                                firestore.collection('drivers').doc(keyss).update({
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
                );
      },
    );
            }
          ),
        );
  }
}