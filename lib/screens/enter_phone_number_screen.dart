import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
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
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        cursorColor: AppColors.primaryColor,
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
                  name: 'ENVOYEZ LE CODE',
                  onTap: () {
                    if (formkey.currentState!.validate())
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VerifyNumberScreen(),
                          ));
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
