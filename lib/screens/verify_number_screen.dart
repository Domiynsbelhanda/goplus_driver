import 'package:flutter/material.dart';
import 'package:goplus_driver/pages/homePage.dart';
import 'package:goplus_driver/screens/checkPage.dart';
import 'package:goplus_driver/screens/enter_phone_number_screen.dart';
import 'package:goplus_driver/utils/global_variables.dart';
import 'package:goplus_driver/utils/otp_text_field.dart';
import 'package:goplus_driver/utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';
import '../widget/app_button.dart';
import '../widget/app_widgets/app_bar.dart';
import '../widget/notification_dialog_auth.dart';
import '../utils/global_variables.dart';

class VerifyNumberScreen extends StatefulWidget {
  bool register;
  String phone;
  String password;
  VerifyNumberScreen({Key? key, required this.phone, required this.register, required this.password}) : super(key: key);

  @override
  _VerifyNumberState createState() => _VerifyNumberState();
}

class _VerifyNumberState extends State<VerifyNumberScreen> {
  late Size size;
  late String code;
  late bool onEditing = false;
  String? otp;
  bool message = false;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                APPBAR(),
                SizedBox(height: size.height * 0.08),
                Text(
                  'Vérification du numéro de téléphone \n+243${widget.phone}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                const SizedBox(height: 8.0,),

                message ? const Text(
                    'Requête envoyée, veuillez patienter.'
                ) : const SizedBox(),

                SizedBox(height: size.height * 0.02),
                SizedBox(
                  height: size.height * 0.05,
                ),
                Center(
                  child: OTPTextField(
                    fieldStyle: FieldStyle.box,
                    onChanged: (val) {
                      setState(() {
                        otp = val;
                      });
                    },
                    onCompleted: (val) {
                      setState(() {
                        otp = val;
                      });
                    },
                    width: size.width * 0.75,
                    fieldWidth: size.width * 0.16,
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                GestureDetector(
                  onTap: (){
                    showLoader("Renvoie OTP en cours...");
                    var data = {
                      "key": "otp",
                      "action": "otp",
                      "phone": widget.phone,
                      "password": widget.password
                    };
                    Provider.of<Auth>(context, listen: false).request(data: data).then((value){
                      disableLoader();
                      setState(() {
                        message = true;
                      });
                    });
                  },
                  child: const Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Vous n\'avez pas réçu de code?',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' RENVOYEZ',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  name: 'VERIFIEZ',
                  color: AppColors.primaryColor,
                  onTap: () async{
                    showLoader("Checking OTP en cours\nVeuillez patienter...");
                    if(otp != null){
                      var data;
                      if(widget.register){
                        data = {
                          'key': "create_user",
                          'action': "rotp",
                          'otp': otp!,
                          'phone': widget.phone,
                          "level": "4"
                        };
                      } else {
                        data = {
                          'key': "check_user",
                          'action': "rotp",
                          'otp': otp!,
                          'phone': widget.phone,
                          "level": "4"
                        };
                      }

                      Provider.of<Auth>(context, listen: false).request(data: data)
                          .then((value){
                            disableLoader();
                        if(value['code'] == 'KO'){
                        } else {
                          storage.write(key: 'sid', value: value['sid']);
                          storage.write(key: 'token', value: data['phone']);
                          if(!widget.register){
                            Navigator.pushAndRemoveUntil(
                              context,
                                MaterialPageRoute(
                                    builder: (context)
                                    => CheckPage()

                                ),
                                (route)=>false
                            );
                          } else {
                            notification_dialog_auth(
                                context,
                                "Votre compte a été crée, veuillez patienter l'activation de la part de GO FLY.",
                                Icons.person,
                                Colors.yellow,
                                {'label': "FERMER", "onTap": (){
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PhoneNumberScreen()
                                    ),
                                      (route)=>false
                                  );
                                }
                                },
                                20,
                                false);
                          }
                        }
                      });
                    }

                    // var ref = firestore.collection('drivers');
                    // var doc = await ref.doc(widget.phone).get();
                    // if(doc.exists){
                    //   storeToken(token: widget.phone);
                    // }
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => doc.exists ? HomePage() : SignupScreen(
                    //       phone: widget.phone,
                    //     ),
                    //   ),
                    // );
                  },
                ),
                SizedBox(height: size.height * 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
