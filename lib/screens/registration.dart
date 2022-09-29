
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxigo_driver/brand_colors.dart';
import 'package:taxigo_driver/globalvariabels.dart';
import 'package:taxigo_driver/screens/login.dart';
import 'package:taxigo_driver/screens/mainpage.dart';
import 'package:taxigo_driver/screens/vehicleinfo.dart';
import 'package:taxigo_driver/widgets/ProgressDialog.dart';
import 'package:taxigo_driver/widgets/TaxiButton.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../translations.dart';

class RegistrationPage extends StatefulWidget {

  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        Fluttertoast.showToast(msg: Translations.of(context).text('no_image'));
      }
    });
  }

  void registerUser() async {

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: Translations.of(context).text('register_you')),
    );

    final User user = (await _auth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    ).catchError((ex){

      //check error and display message
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);

    })).user;

    Navigator.pop(context);
    // check if user registration is successful
    if(user != null){

      var url = await uploadFile(_image, user.uid);

      DatabaseReference newUserRef = FirebaseDatabase.instance.reference().child('drivers/${user.uid}');

      //Prepare data to be saved on users table
      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'image': url.toString()
      };

      newUserRef.set(userMap);

      currentFirebaseUser = user;

      //Take the user to the mainPage
      Navigator.pushNamed(context, VehicleInfoPage.id);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.width / 15),
                
                GestureDetector(
                  child : circleImage(context),
                  onTap: getImage
                ),
                Text(Translations.of(context).text('picture_profil')),

                SizedBox(height: MediaQuery.of(context).size.width / 15,),

                Text(Translations.of(context).text('create_driver'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width / 16, fontFamily: 'Brand-Bold'),
                ),

                Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width / 22),
                  child: Card(
                    elevation: 2.0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Column(
                      children: <Widget>[
                        // Fullname
                        TextField(
                          controller: fullNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: Translations.of(context).text('full_name'),
                              labelStyle: TextStyle(
                                fontSize: MediaQuery.of(context).size.width / 23,
                              ),
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.width / 25
                              )
                          ),
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width / 22),
                        ),

                        SizedBox(height: 5.0),

                        // Email Address
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: Translations.of(context).text('email'),
                              labelStyle: TextStyle(
                                fontSize: MediaQuery.of(context).size.width / 23,
                              ),
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.width / 25
                              )
                          ),
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width / 22),
                        ),

                        SizedBox(height: 5.0,),


                        // Phone
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: Translations.of(context).text('phone'),
                              labelStyle: TextStyle(
                                fontSize: MediaQuery.of(context).size.width / 23,
                              ),
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.width / 25
                              )
                          ),
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width / 22),
                        ),

                        SizedBox(height: 5.0,),

                        // Password
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: Translations.of(context).text('password'),
                              labelStyle: TextStyle(
                                fontSize: MediaQuery.of(context).size.width / 23,
                              ),
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.width / 25
                              )
                          ),
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width / 22),
                        ),

                      ],
                    ),
                                      ),
                  ),
                ),

                TaxiButton(
                          title: Translations.of(context).text('register'),
                          color: Colors.black,
                          onPressed: () async{

                            //check network availability

                            var connectivityResult = await Connectivity().checkConnectivity();
                            if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                              showSnackBar('No internet connectivity');
                              return;
                            }

                            if(fullNameController.text.length < 3){
                              showSnackBar(Translations.of(context).text('provide_fullname'));
                              return;
                            }

                            if(phoneController.text.length < 10){
                              showSnackBar(Translations.of(context).text('provide_number'));
                              return;
                            }

                            if(!emailController.text.contains('@')){
                              showSnackBar(Translations.of(context).text('valide_mail'));
                              return;
                            }

                            if(passwordController.text.length < 8){
                              showSnackBar(Translations.of(context).text('length_password'));
                              return;
                            }

                            registerUser();

                          },
                        ),

                FlatButton(
                    onPressed: (){
                      Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                    },
                    child: Text(Translations.of(context).text('ready_account'),  style: TextStyle(color: Colors.white))
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> uploadFile(file, uid) async{

      // Create a Reference to the file
      Reference postImageRef = FirebaseStorage.instance
          .ref()
          .child('profile')
          .child('/$uid.jpg');

      //final firebase_storage.UploadTask uploadTask = postImageRef.putFile(file);

      TaskSnapshot storageTaskSnapshot = await postImageRef.putFile(file);
    // TaskSnapshot storageTaskSnapshot =  uploadTask.snapshot;

      var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl.toString();
  }

  Widget circleImage(context){
    return Container(
      height: MediaQuery.of(context).size.width / 4,
      width: MediaQuery.of(context).size.width / 4,
      margin: EdgeInsets.only(
        left: 5.0,
        right: 5.0
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(
          width: 2.0,
          style:BorderStyle.solid ,
          color: Color.fromARGB(255, 0 , 0, 0)
      ),
      image: DecorationImage(
        fit: BoxFit.cover,
        image: _image == null ?
          NetworkImage("https://www.materialui.co/materialIcons/action/account_circle_white_48x48.png")
          : FileImage(_image)
        )
      )
    );
  }
}
