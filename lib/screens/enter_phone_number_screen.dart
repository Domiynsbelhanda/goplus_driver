import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goplus_driver/screens/signup_screen.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:provider/provider.dart';
import '../pages/homePage.dart';
import '../utils/app_colors.dart';
import '../utils/global_variables.dart';
import '../widget/app_button.dart';
import '../widget/app_widgets/app_bar.dart';
import 'verify_number_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {

  late Size size;
  final formkey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                APPBAR(),
                SizedBox(height: size.height * 0.08),
                Text(
                  'Entrez votre numéro de téléphone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(height: size.height * 0.05),
                Text(
                  'Respectez comme indiqué dans l\'exemple.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: size.height * 0.06,
                      width: size.height * 0.08,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                          border: Border.all(
                        color: AppColors.primaryColor,
                      )),
                      child: Text(
                        "+243",
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                        child: Form(
                      key: formkey,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Numéro de téléphone incorrect';
                          }
                          if(value.length != 9){
                            return 'Numéro de téléphone incorrect, vérifiez.';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        cursorColor: AppColors.primaryColor,
                        controller: phoneController,
                        decoration: InputDecoration(
                          hintText: "812345678",
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                      ),
                    ))
                  ],
                ),
                SizedBox(height: size.height * 0.08),
                AppButton(
                  color: AppColors.primaryColor,
                  name: 'CONNEXION',
                  onTap: () async {
                    if (formkey.currentState!.validate()){
                      var data = {
                        'key': 'otp',
                        'phone': phoneController.text.trim()
                      };
                      Provider.of<Auth>(context, listen: false).sendOtp(context, data);
                      // var ref = FirebaseFirestore.instance.collection('drivers');
                      // var doc = await ref.doc(phoneController.text.trim()).get();
                      // if(doc.exists){
                      //   storeToken(token: phoneController.text.trim());
                      // }
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => doc.exists ? HomePage(
                      //       phone: phoneController.text.trim(),
                      //     ) : SignupScreen(
                      //       phone: phoneController.text.trim(),
                      //     ),
                      //   ),
                      // );
                    }
                  },
                ),
                SizedBox(height: size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
