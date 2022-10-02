import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:goplus_driver/widget/notification_dialog.dart';

import '../utils/app_colors.dart';

progresso_dialog(
    BuildContext contexts,
    String text,) async {

  await Future.delayed(Duration(microseconds: 1));

  double width = MediaQuery.of(contexts).size.width;

  // show the dialog
  showDialog(
    context: contexts,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20.0)),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('drivers')
              .doc(text).collection('courses').doc('courses').get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

            return SizedBox(
              width: width / 1,
              height: width /1.3,
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children : [
                        Text(
                          'En attente de la réponse',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                        TimerCountdown(
                          secondsDescription: 'Secondes',
                          minutesDescription: 'Minutes',
                          timeTextStyle: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                          ),
                          format: CountDownTimerFormat.minutesSeconds,
                          endTime: DateTime.now().add(
                            Duration(
                              minutes: 1,
                              seconds: 40,
                            ),
                          ),
                          onEnd: () {
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

                        Row(
                          children: [
                            TextButton(
                              child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: Text(
                                    'VOIR',
                                    style: TextStyle(
                                        color: Colors.black
                                    ),
                                  )
                              ),
                              onPressed: (){
                                FirebaseFirestore.instance.collection('drivers').doc(text).update({
                                  'online': true,
                                  'ride': false
                                });
                                FirebaseFirestore.instance.collection('drivers').doc(text).collection('courses')
                                    .doc('courses').delete();
                                Navigator.pop(context);
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
                                  child: Text(
                                    'REFUSER',
                                    style: TextStyle(
                                        color: Colors.black
                                    ),
                                  )
                              ),
                              onPressed: (){
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
          },
        )
      );
    },
  );
}