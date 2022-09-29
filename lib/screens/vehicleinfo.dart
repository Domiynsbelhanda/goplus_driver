import 'package:taxigo_driver/brand_colors.dart';
import 'package:taxigo_driver/globalvariabels.dart';
import 'package:taxigo_driver/screens/mainpage.dart';
import 'package:taxigo_driver/widgets/TaxiButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../translations.dart';

class VehicleInfoPage extends StatelessWidget {


  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  static const String id = 'vehicleinfo';

  var carModelController = TextEditingController();
  var carColorController = TextEditingController();
  var vehicleNumberController = TextEditingController();

  void updateProfile(context){

    String id = currentFirebaseUser.uid;
    DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child('drivers/$id/vehicle_details');

    Map map = {
      'car_color': carColorController.text,
      'car_model': carModelController.text,
      'vehicle_number': vehicleNumberController.text,
    };

    driverRef.set(map);

    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            
            children: <Widget>[

              SizedBox(height: 30,),

              Image.asset('images/logo.png', height: 100, width: 100,),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: <Widget>[

                    SizedBox(height: 10,),

                    Text(Translations.of(context).text('car_detail'), style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 22),),

                    SizedBox(height: 25,),

                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: Translations.of(context).text('car_model'),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),

                    SizedBox(height: 10.0),

                    TextField(
                      controller: carColorController,
                      decoration: InputDecoration(
                          labelText: Translations.of(context).text('car_color'),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),

                    SizedBox(height: 10.0),

                    TextField(
                      controller: vehicleNumberController,
                      maxLength: 11,
                      decoration: InputDecoration(
                          counterText: '',
                          labelText: Translations.of(context).text('vehicule_number'),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),

                    SizedBox(height: 40.0),

                    TaxiButton(
                      color: BrandColors.colorGreen,
                      title: Translations.of(context).text('proceed'),
                      onPressed: (){


                        if(carModelController.text.length < 3){
                          showSnackBar(Translations.of(context).text('model_provide'));
                          return;
                        }

                        if(carColorController.text.length < 3){
                          showSnackBar(Translations.of(context).text('color_provide'));
                          return;
                        }

                        if(vehicleNumberController.text.length < 3){
                          showSnackBar(Translations.of(context).text('vehicule_number_provide'));
                          return;
                        }

                        updateProfile(context);

                      },
                    )


                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
