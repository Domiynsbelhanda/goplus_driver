
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';
import 'package:taxigo_driver/brand_colors.dart';
import 'package:taxigo_driver/screens/mainpage.dart';
import 'package:taxigo_driver/screens/registration.dart';
import 'package:taxigo_driver/widgets/ProgressDialog.dart';
import 'package:taxigo_driver/widgets/TaxiButton.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../application.dart';
import '../globalvariabels.dart';
import './../translations.dart';

class LoginPage extends StatefulWidget {

  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void login(context) async {

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: Translations.of(context).text('login_you'),),
    );

    final User user = (await _auth.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    ).catchError((ex){

      //check error and display message
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);

    })).user;

    if(user != null){
      // verify login
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('drivers/${user.uid}');
      userRef.once().then((DataSnapshot snapshot) {

        if(snapshot.value != null){
          Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
        }
      });

    }
  }

  String value = langue;
  List<S2Choice<String>> options = [
    S2Choice<String>(value: 'en', title: 'Anglais'),
    S2Choice<String>(value: 'fr', title: 'Français'),
    S2Choice<String>(value: 'ar', title: 'Arabe'),
  ];

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

              SmartSelect<String>.single(
                title: 'Langue',
                value: value,
                choiceItems: options,
                onChange: (state) async{
                  value = state.value;
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('langue', value);
                  applic.onLocaleChanged(new Locale(value,''));
                  (context as Element).markNeedsBuild();
                }
              ),

                SizedBox(height: MediaQuery.of(context).size.width / 8,),
                Image(
                  alignment: Alignment.center,
                  height:  MediaQuery.of(context).size.width / 4,
                  width: MediaQuery.of(context).size.width / 4,
                  image: AssetImage('images/logo.png'),
                ),

                SizedBox(height: MediaQuery.of(context).size.width / 9,),

                Text(Translations.of(context).text('login_driver'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width / 14, fontFamily: 'Brand-Bold', color: Colors.white),
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

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: Translations.of(context).text('email'),
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: MediaQuery.of(context).size.width / 23,
                              ),
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.width / 25
                              )
                          ),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 22),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.width / 30,),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: Translations.of(context).text('password'),
                              labelStyle: TextStyle(
                                color: Colors.black,
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
                      )
                  ),
                ),

                TaxiButton(
                          title: Translations.of(context).text('login'),
                          color: Colors.black12,
                          onPressed: () async {

                            //check network availability

                            var connectivityResult = await Connectivity().checkConnectivity();
                            if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                              showSnackBar('No internet connectivity');
                              return;
                            }

                            if(!emailController.text.contains('@')){
                              showSnackBar(Translations.of(context).text('valide_mail'));
                              return;
                            }

                            if(passwordController.text.length < 8){
                              showSnackBar(Translations.of(context).text('valide_password'));
                              return;
                            }

                            login(context);

                          },
                        ),

                FlatButton(
                    onPressed: (){
                      Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
                    },
                    child: Text(Translations.of(context).text('no_account'), style: TextStyle(color: Colors.white))
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}

