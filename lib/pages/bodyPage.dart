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

class BodyPage extends StatefulWidget{
  BodyPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BodyPage();
  }
}

class _BodyPage extends State<BodyPage>{

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

    return Text('Belhanda');
  }
}