import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_select/smart_select.dart';
import '../services/auth.dart';
import '../utils/app_colors.dart';
import '../widget/app_button.dart';
import '../widget/app_widgets/app_bar.dart';

class SignupScreen extends StatefulWidget {

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late Size size;
  final formkey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController postNomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController villeController = TextEditingController();
  TextEditingController carPlaqueController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late List input;

  String value = 'H';
  List<S2Choice<String>> options = [
    S2Choice<String>(value: 'h', title: 'Homme'),
    S2Choice<String>(value: 'f', title: 'Femme'),
  ];

  String carType = '1';
  List<S2Choice<String>> carTypeoptions = [
    S2Choice<String>(value: '1', title: 'Mini'),
    S2Choice<String>(value: '2', title: 'Berline'),
    S2Choice<String>(value: '3', title: 'Mini Vanne'),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    input = [
      {
        'label': 'Numéro téléphone', 'controller' : phoneController, 'input': TextInputType.phone
      },
      {
        'label': 'Mot de passe', 'controller' : passwordController, 'input': TextInputType.visiblePassword
      },
      {
        'label': 'Nom', 'controller' : nameController
      },
      {
        'label': 'PostNom', 'controller' : postNomController
      },
      {
        'label': 'Prénom', 'controller' : prenomController
      },
      {
        'label': 'Adresse', 'controller' : adresseController, 'input': TextInputType.streetAddress
      },
      {
        'label': 'Ville', 'controller' : villeController
      },
      {
        'label': 'Plaque', 'controller' : carPlaqueController
      },
    ];
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
                SizedBox(
                  width: size.width,
                  child: const Text(
                    'Inscription',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: size.width * 0.6,
                  child: const Text(
                    'Créer votre compte pour chauffeur.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      Column(
                          children: input.map((e){
                            return TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '${e['label']} incorect';
                                }
                                return null;
                              },
                              cursorColor: AppColors.primaryColor,
                              keyboardType: e['input'] == null ? TextInputType.name : e['input'],
                              controller: e['controller'],
                              decoration: InputDecoration(
                                  hintText: '${e['label']}',
                                  contentPadding: EdgeInsets.all(15.0)),
                            );
                          }).toList()
                      ),

                      SmartSelect<String>.single(
                          title: 'Genre',
                          value: value,
                          choiceItems: options,
                          onChange: (state) => setState(() => value = state.value)
                      ),

                      SmartSelect<String>.single(
                          title: 'Type de voiture',
                          value: carType,
                          choiceItems: carTypeoptions,
                          onChange: (state) => setState(() => carType = state.value)
                      ),

                      SizedBox(height: size.height * 0.07),
                      AppButton(
                          name: 'S\'INSRIRE',
                          color: AppColors.primaryColor,
                          onTap: (){

                            if(formkey.currentState!.validate()){
                              var data = {
                                "key": "create_user",
                                "action": "driver",
                                "lastn": prenomController.text.toString(),
                                "midn": postNomController.text.toString(),
                                "firstn": nameController.text.toString(),
                                "address": adresseController.text.toString(),
                                "password": passwordController.text.trim(),
                                "city": villeController.text.toString(),
                                "phone": phoneController.text.toString(),
                                "gender": value,
                                "cartype": carType,
                                'carplate': carPlaqueController.text.toString(),
                              };

                              Provider.of<Auth>(context, listen: false).register(context: context, cred: data);
                            }
                          }),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
