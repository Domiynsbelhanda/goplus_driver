import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final storage = new FlutterSecureStorage();
FirebaseFirestore firestore = FirebaseFirestore.instance;
bool? online;

void storeToken({required String token}) async{
  await storage.write(key: 'token', value: token);
}

Future<List<BitmapDescriptor>> bitmapicon() async{
  BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(),
    "assets/images/car_android.png",
  );

  BitmapDescriptor departBitmap = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(),
    "assets/images/drapeau-a-damier.png",
  );

  BitmapDescriptor arriveBitmap = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(),
    "assets/images/drapeau.png",
  );
  return [
    markerbitmap,
    departBitmap,
    arriveBitmap
  ];
}

void deleteToken(String key) async{
  await storage.delete(key: key);
}

double calculateDistance(LatLng latLng1, LatLng latLng2){
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((latLng2.latitude - latLng1.latitude) * p)/2 +
      c(latLng1.latitude * p) * c(latLng2.latitude * p) *
          (1 - c((latLng2.longitude - latLng1.longitude) * p))/2;
  return 1000 * 12742 * asin(sqrt(a));
}