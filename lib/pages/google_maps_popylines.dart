
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/widget/app_button.dart';
import 'package:location/location.dart';

import '../widget/backButton.dart';

class GoogleMapsPolylines extends StatefulWidget {
  LatLng origine;
  LatLng destination;
  LatLng position;
  String id;
  String? phone;

  GoogleMapsPolylines({Key? key, this.phone, required this.id, required this.origine, required this.destination, required this.position}) : super(key: key);

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

      setState(() {
        _markers.clear();
        _markers.add(
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
      widget.position,
      widget.origine,
      widget.destination,
    ];

    _kGoogle = CameraPosition(
      target: widget.position,
      zoom: 14,
    );

    // declared for loop for various locations
    for(int i=0; i<latLen.length; i++){
      _markers.add(
        // added markers
          Marker(
            markerId: MarkerId(i.toString()),
            position: latLen[i],
            infoWindow: InfoWindow(
              title: '${i + 1} ${i == 0 ? 'Votre Position' : i == 1 ? 'Lieu de ramassage' : i == 2 ? 'Destination du client' : ''}',
              snippet: '',
            )
          )
      );
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
            child: AppButton(
              onTap: (){},
              name: 'DEMARRER LA COURSE',
              color: Colors.yellow,
            )
        ) : SizedBox(),
      ],
    );
  }
}