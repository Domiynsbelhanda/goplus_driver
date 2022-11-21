import 'package:flutter/material.dart';
import 'package:goplus_driver/screens/signup_screen.dart';
import 'package:goplus_driver/services/auth.dart';
import 'package:goplus_driver/widget/notification_dialog_auth.dart';
import 'package:provider/provider.dart';
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
  TextEditingController passwordController = TextEditingController();

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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CONNEXION',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26.0
                ),
              ),

              SizedBox(height: size.height * 0.09,),

              const Text(
                'Entrez votre numéro de téléphone',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0
                ),
              ),

              SizedBox(height: size.height * 0.02),
              SizedBox(height: size.height * 0.05),
              const Text(
                'Respectez comme indiqué dans l\'exemple.',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.02),

              Form(
                key: formkey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: size.height * 0.06,
                          width: size.height * 0.08,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryColor,
                              )),
                          child: const Text(
                            "+243",
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10.0,),

                        Expanded(
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
                            maxLength: 9,
                            decoration: const InputDecoration(
                              hintText: "812345678",
                              contentPadding: EdgeInsets.all(10.0),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0,),

                    SizedBox(
                      width: size.width,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || value.length < 6) {
                            return 'Entrez un mot de passe valide';
                          }
                          return null;
                        },
                        cursorColor: AppColors.primaryColor,
                        keyboardType: TextInputType.visiblePassword,
                        controller: passwordController,
                        decoration: const InputDecoration(
                            hintText: 'Mot de passe',
                            contentPadding: EdgeInsets.all(15.0)),
                      ),
                    ),

                    SizedBox(height: size.height * 0.08),
                    AppButton(
                      color: AppColors.primaryColor,
                      name: 'CONNEXION',
                      onTap: () async {
                        if (formkey.currentState!.validate()){
                          showLoader("Connexion en cours...\nVeuillez patienter...");
                          var data = {
                            "key": "check_user",
                            "action": "driver",
                            "phone": phoneController.text.trim(),
                            "password": passwordController.text.trim()
                          };
                          Provider.of<Auth>(context, listen: false)
                              .request(data: data).then((value){
                                disableLoader();
                                if(value['code'].toString() == '400'){
                                  notification_dialog_auth(
                                      context,
                                      '${value['message']}',
                                      Icons.person,
                                      Colors.yellow,
                                      {'label': 'FERMER', "onTap": (){
                                        Navigator.pop(context);
                                      }},
                                      20,
                                      false);
                                } else if(value['code'].toString() == '401'){
                                  notification_dialog_auth(
                                      context,
                                      'Compte en attente d\'activation',
                                      Icons.person,
                                      Colors.yellow,
                                      {'label': 'FERMER', "onTap": (){
                                        Navigator.pop(context);
                                      }},
                                      20,
                                      false);
                                }
                                else if(value['code'] == "OTP"){
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                      MaterialPageRoute(
                                          builder: (context)
                                          => VerifyNumberScreen(
                                              password: passwordController.text.trim(),
                                              register: false,
                                              phone: phoneController.text.trim())

                                      ),
                                      (route)=> false
                                  );
                                }

                                else if(value['code'] == '500'){
                                  notification_dialog_auth(
                                      context,
                                      "Impossible de se connecter au serveur OTP.",
                                      Icons.person,
                                      Colors.yellow,
                                      {'label': "FERMER", "onTap": (){
                                        Navigator.pop(context);
                                      }
                                      },
                                      20,
                                      false);
                                }

                                else if(value['code'] == 'KO'){
                                  notification_dialog_auth(
                                      context,
                                      "${value['message']}",
                                      Icons.person,
                                      Colors.yellow,
                                      {'label': "CREER UN COMPTE", "onTap": (){
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context)
                                                => const SignupScreen()

                                            ),
                                                (route)=> false
                                        );
                                      }
                                      },
                                      20,
                                      false);
                                }
                                else if (value['code'] == 'NOK'){
                                  notification_dialog_auth(
                                      context,
                                      "${value['message']}",
                                      Icons.person,
                                      Colors.yellow,
                                      {'label': "FERMER", "onTap": (){
                                        Navigator.pop(context);
                                      }
                                      },
                                      20,
                                      false);
                                } else {
                                  notification_dialog_auth(
                                      context,
                                      "Une erreur c'est produite.",
                                      Icons.person,
                                      Colors.yellow,
                                      {'label': "FERMER", "onTap": (){
                                        Navigator.pop(context);
                                      }
                                      },
                                      20,
                                      false);
                                }

                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16.0,),

                    GestureDetector(
                      onTap: (){
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                              const SignupScreen()
                          ),
                                (route)=>false
                        );
                      },
                      child: const Text(
                        'Pas de compte? Créez en un.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.1),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
