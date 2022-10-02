import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

import '../utils/app_colors.dart';

progresso_dialog(
    BuildContext contexts,
    String text,) async {

  await Future.delayed(Duration(microseconds: 1));

  double width = MediaQuery.of(contexts).size.width;

  // show the dialog
  showDialog(
    context: contexts,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20.0)),
        child: SizedBox(
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
                      timeTextStyle: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold
                      ),
                      format: CountDownTimerFormat.secondsOnly,
                      endTime: DateTime.now().add(
                        Duration(
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
                            .doc('courses').delete();
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
                                'REFUSER',
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

                        const SizedBox(width: 8.0),

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
                                .doc('courses').delete();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                  ]
              )
          ),
        ),
      );
    },
  );
}