import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goplus_driver/pages/google_maps_popylines.dart';
import 'package:goplus_driver/screens/loadingAnimationWidget.dart';
import 'package:vibration/vibration.dart';

import '../utils/app_colors.dart';

progresso_dialog(
    BuildContext contexts,
    String text) async {

  await Future.delayed(const Duration(microseconds: 1));

  double width = MediaQuery.of(contexts).size.width;

  final Key mapKey = UniqueKey();

  // show the dialog
  showDialog(
    context: contexts,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20.0)),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('drivers')
              .doc(text).collection('courses').doc('courses').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

            if(!snapshot.hasData){
              return LoadingWidget(message: 'Pas de course, veuillez patienter.',);
            }
            
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

            if(data['status'] == 'cancel'){
              return SizedBox(
                width: width / 1,
                height: width / 1.1,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        children : [
                          Icon(
                            Icons.close,
                            color: Colors.red,
                            size: width / 5,
                          ),

                          const SizedBox(height: 16.0),

                          SizedBox(
                            width : width / 1.5,
                            child: const Text(
                                'La commande a été annulée par le client.',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                )
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          TextButton(
                            child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(8.0)
                                ),
                                child: const Text(
                                  'FERMER',
                                  style: TextStyle(
                                      color: Colors.black
                                  ),
                                )
                            ),
                            onPressed: (){
                              try{
                                FirebaseFirestore.instance.collection('drivers').doc(text).collection('courses')
                                    .doc('courses')
                                    .delete();
                              } catch(e){

                              }
                              Navigator.pop(context);
                            },
                          )
                        ]
                    )
                ),
              );
            } else {
              Vibration.vibrate(amplitude: 128, duration: 5000);
              return SizedBox(
                width: width / 1,
                height: data['status'] == 'see' ? MediaQuery.of(context).size.height - 64 : width /1.3,
                child: Padding(
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
                                minutes: 1,
                                seconds: 40,
                              ),
                            ),
                            onEnd: () {
                              Vibration.cancel();
                              FirebaseFirestore.instance.collection('drivers').doc(text).update({
                                'online': true,
                                'ride': false,
                                'ride_view': false
                              });
                              FirebaseFirestore.instance.collection('drivers').doc(text).collection('courses')
                                  .doc('courses')
                                  .update({
                                'status': 'cancel',
                              });
                              Navigator.pop(context);
                            },
                          ),

                          data['status'] == 'see' ?
                              SizedBox(
                                height: MediaQuery.of(context).size.width,
                                child: GoogleMapsPolylines(
                                  destination: LatLng(data['destination_latitude'], data['destination_longitude']),
                                  origine: LatLng(data['depart_latitude'], data['depart_longitude']),
                                  id: text,
                                  key: mapKey,
                                ),
                              )
                          : const SizedBox(),

                          data['status'] == 'see' ?
                          Row(
                            children: [
                              TextButton(
                                child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(8.0)
                                    ),
                                    child: const Text(
                                      'ACCEPTER',
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                onPressed: (){
                                  Vibration.cancel();
                                  FirebaseFirestore.instance.collection('drivers').doc(text).collection('courses')
                                      .doc('courses')
                                      .update({
                                    'status': 'accept',
                                  });
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              GoogleMapsPolylines(
                                                  destination: LatLng(data['destination_latitude'], data['destination_longitude']),
                                                  origine: LatLng(data['depart_latitude'], data['depart_longitude']),
                                                  id: text,
                                                  phone: data['user_id'],
                                                key: mapKey,
                                              )
                                      ),
                                          (Route<dynamic> route) => false
                                  );
                                },
                              ),

                              const SizedBox(width: 4.0),

                              TextButton(
                                child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(8.0)
                                    ),
                                    child: const Text(
                                      'REFUSER',
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                onPressed: (){
                                  Vibration.cancel();
                                  FirebaseFirestore.instance.collection('drivers').doc(text).update({
                                    'online': true,
                                    'ride': false,
                                    'ride_view': false
                                  });
                                  FirebaseFirestore.instance.collection('drivers').doc(text).collection('courses')
                                      .doc('courses')
                                      .update({
                                    'status': 'cancel',
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              TextButton(
                                child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(8.0)
                                    ),
                                    child: const Text(
                                      'VOIR',
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                onPressed: (){
                                  Vibration.cancel();
                                  FirebaseFirestore.instance.collection('drivers').doc(text).collection('courses')
                                      .doc('courses')
                                      .update({
                                    'status': 'see',
                                  });
                                },
                              ),

                              const SizedBox(width: 4.0),

                              TextButton(
                                child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(8.0)
                                    ),
                                    child: const Text(
                                      'REFUSER',
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                onPressed: (){
                                  Vibration.cancel();
                                  FirebaseFirestore.instance.collection('drivers').doc(text).update({
                                    'online': true,
                                    'ride': false,
                                    'ride_view': false
                                  });
                                  FirebaseFirestore.instance.collection('drivers').doc(text).collection('courses')
                                      .doc('courses')
                                      .update({
                                    'status': 'cancel',
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          )
                        ]
                    )
                ),
              );
            }
          },
        )
      );
    },
  );
}