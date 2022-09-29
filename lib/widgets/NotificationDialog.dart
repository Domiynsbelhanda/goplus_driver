import 'package:fluttertoast/fluttertoast.dart';
import 'package:taxigo_driver/brand_colors.dart';
import 'package:taxigo_driver/datamodels/tripdetails.dart';
import 'package:taxigo_driver/globalvariabels.dart';
import 'package:taxigo_driver/helpers/helpermethods.dart';
import 'package:taxigo_driver/screens/newtripspage.dart';
import 'package:taxigo_driver/widgets/BrandDivier.dart';
import 'package:taxigo_driver/widgets/ProgressDialog.dart';
import 'package:taxigo_driver/widgets/TaxiButton.dart';
import 'package:taxigo_driver/widgets/TaxiOutlineButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {

  final TripDetails tripDetails;

  NotificationDialog({this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            SizedBox(height: MediaQuery.of(context).size.width / 10,),

            Image.asset('images/taxi.png', width: MediaQuery.of(context).size.width / 6,),

            SizedBox(height: 16.0,),

            Text('NEW TRIP REQUEST', style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),),

            SizedBox(height: 30.0,),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(

                children: <Widget>[

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset('images/pickicon.png', height: 16, width: 16,),
                      SizedBox(width: 18,),

                      Expanded(child: Container(child: Text(tripDetails.pickupAddress, style: TextStyle(fontSize: MediaQuery.of(context).size.width / 25),)))


                    ],
                  ),

                  SizedBox(height: 15,),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset('images/desticon.png', height: 16, width: 16,),
                      SizedBox(width: 18,),

                      Expanded(child: Container(child: Text(tripDetails.destinationAddress, style: TextStyle(fontSize: MediaQuery.of(context).size.width / 25),)))


                    ],
                  ),

                ],
              ),
            ),

            SizedBox(height: 20,),

            BrandDivider(),

            SizedBox(height: 8,),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    child: Container(
                      child: TaxiOutlineButton(
                        title: 'DECLINE',
                        color: BrandColors.colorPrimary,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 10,),

                  Expanded(
                    child: Container(
                      child: TaxiButton(
                        title: 'ACCEPT',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          checkAvailablity(context);
                        },
                      ),
                    ),
                  ),

                ],
              ),
            ),

            SizedBox(height: 10.0,),

          ],
        ),
      ),
    );
  }

  void checkAvailablity(context){

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Accepting request',),
    );

    DatabaseReference newRideRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newtrip');
    newRideRef.once().then((DataSnapshot snapshot) {

      Navigator.pop(context);
      Navigator.pop(context);

      String thisRideID = "";
      if(snapshot.value != null){
        thisRideID = snapshot.value.toString();
      }
      else{
        Fluttertoast.showToast(msg: "Ride not found");
      }

      if(thisRideID == tripDetails.rideID){
        newRideRef.set('accepted');
        HelperMethods.disableHomTabLocationUpdates();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewTripPage(tripDetails: tripDetails,),
        ));
      }
      else if(thisRideID == 'cancelled'){
        Fluttertoast.showToast(msg: "Ride has been cancelled");
      }
      else if(thisRideID == 'timeout'){
        Fluttertoast.showToast(msg: "Ride has timed out");
      }
      else{
        Fluttertoast.showToast(msg: "Ride not found");
      }

    });
  }

}
