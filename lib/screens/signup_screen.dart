import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';
import '../widget/app_button.dart';
import '../widget/app_widgets/app_bar.dart';
import 'enter_phone_number_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                APPBAR(),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Container(
                  width: size.width * 0.3,
                  child: Text(
                    'Inscription',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  width: size.width * 0.6,
                  child: Text(
                    '_localeText.signUpBody',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Nom incorect';
                          }
                          return null;
                        },
                        cursorColor: AppColors.primaryColor,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            hintText: '_localeText.fullName',
                            prefixIcon: Icon(Icons.person),
                            contentPadding: EdgeInsets.all(15.0)),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '_localeText.emailError';
                          }
                          return null;
                        },
                        cursorColor: AppColors.primaryColor,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            hintText: '_localeText.email',
                            prefixIcon: Icon(Icons.mail),
                            contentPadding: EdgeInsets.all(15.0)),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '_localeText.passwordError';
                          }
                          return null;
                        },
                        obscureText: true,
                        cursorColor: AppColors.primaryColor,
                        decoration: InputDecoration(
                            hintText: '_localeText.password',
                            prefixIcon: Icon(Icons.lock),
                            contentPadding: EdgeInsets.all(15.0)),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '_localeText.confirmPassError';
                          }
                          return null;
                        },
                        obscureText: true,
                        cursorColor: AppColors.primaryColor,
                        decoration: InputDecoration(
                            hintText: '_localeText.confirmPass',
                            prefixIcon: Icon(Icons.lock),
                            contentPadding: EdgeInsets.all(15.0)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.07),
                AppButton(
                    name: '_localeText.signUpBtn',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhoneNumberScreen(),
                        ))),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
