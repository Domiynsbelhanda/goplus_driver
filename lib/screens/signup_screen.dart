import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goplus_driver/screens/verify_number_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';
import '../utils/app_colors.dart';
import '../utils/global_variables.dart';
import '../widget/app_button.dart';
import '../widget/app_widgets/app_bar.dart';
import '../widget/notification_dialog_auth.dart';
import 'checkPage.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late Size size;
  final formkey = GlobalKey<FormState>();
  File? imageFile;

  TextEditingController nameController = TextEditingController();
  TextEditingController postNomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController villeController = TextEditingController();
  TextEditingController carPlaqueController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late List input;

  int genreTag = 0;
  List<Map<String, dynamic>> genreOptions = [
    {
      'name': 'Homme',
      'value' : 'H'
    },
    {
      'name': 'Femme',
      'value' : 'F'
    }
  ];

  int carTypeTag = 0;
  List<Map<String, dynamic>> carOptions = [
    {
      'name': 'Mini',
      'value' : '1'
    },
    {
      'name': 'Berline VIP',
      'value' : '2'
    }
  ];

  int colorTag = 0;
  List<Map<String, dynamic>> colorOptions = [
    {
      'name': 'Jaune',
      'value' : 'Jaune'
    },
    {
      'name': 'Rouge',
      'value' : 'Rouge'
    },

    {
      'name': 'Bleue',
      'value' : 'Bleue'
    },

    {
      'name': 'Grise',
      'value' : 'Grise'
    },
    {
      'name': 'Noire',
      'value' : 'Noire'
    },
    {
      'name': 'Verte',
      'value' : 'Verte'
    },
    {
      'name': 'Orange',
      'value' : 'Orange'
    },
    {
      'name': 'Blanche',
      'value' : 'Blanche'
    }
  ];

  /// Get from gallery
  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    _cropImage(pickedFile?.path);
  }

  /// Crop Image
  _cropImage(filePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile  != null) {
      imageFile = File(croppedFile.path) ;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    input = [
      {
        'label': 'Numéro téléphone',
        'controller' : phoneController,
        'input': TextInputType.phone,
        'max': 9
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
        'label': 'Plaque d\'immatriculation', 'controller' : carPlaqueController
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
                  Container(
                  child: imageFile == null
                              ? Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                      color: const Color(0XFF307777),
                                      onPressed: () {
                                        _getFromGallery();
                                      },
                                      icon: const Text(
                                        "PICK FROM GALLERY",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : SizedBox(
                              child: Image.file(
                              imageFile!,
                              fit: BoxFit.cover,
                            ),
                      )),
                      Column(
                          children: input.map((e){
                            if(e['max'] != null){
                              return Row(
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
                                  SizedBox(
                                    width: size.width / 1.4,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return '${e['label']} incorect';
                                        }
                                        return null;
                                      },
                                      cursorColor: AppColors.primaryColor,
                                      maxLength: e['max'] ?? null,
                                      keyboardType: e['input'] == null ? TextInputType.name : e['input'],
                                      controller: e['controller'],
                                      decoration: InputDecoration(
                                          hintText: '${e['label']}',
                                          contentPadding: EdgeInsets.all(15.0)),
                                    ),
                                  )
                                ],
                              );
                            }
                            return TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '${e['label']} incorect';
                                }
                                return null;
                              },
                              cursorColor: AppColors.primaryColor,
                              maxLength: e['max'] == null ? null : e['max'],
                              keyboardType: e['input'] == null ? TextInputType.name : e['input'],
                              controller: e['controller'],
                              decoration: InputDecoration(
                                  hintText: '${e['label']}',
                                  contentPadding: const EdgeInsets.all(15.0)),
                            );
                          }).toList()
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                              'Genre :',
                              style: TextStyle(
                                  fontSize: size.width / 25
                              )
                          ),
                          ChipsChoice<int>.single(
                            value: genreTag,
                            onChanged: (val) => setState(() => genreTag = val),
                            choiceItems: C2Choice.listFrom<int, Map<String, dynamic>>(
                              source: genreOptions,
                              value: (i, v) => i,
                              label: (i, v) => v['name'],
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                              'Car Type :',
                              style: TextStyle(
                                  fontSize: size.width / 25
                              )
                          ),
                          ChipsChoice<int>.single(
                            value: carTypeTag,
                            onChanged: (val) => setState(() => carTypeTag = val),
                            choiceItems: C2Choice.listFrom<int, Map<String, dynamic>>(
                              source: carOptions,
                              value: (i, v) => i,
                              label: (i, v) => v['name'],
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                              'Couleur :',
                              style: TextStyle(
                                  fontSize: size.width / 25
                              )
                          ),
                          SizedBox(
                            width: size.width / 1.4,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ChipsChoice<int>.single(
                                value: colorTag,
                                onChanged: (val) => setState(() => colorTag = val),
                                choiceItems: C2Choice.listFrom<int, Map<String, dynamic>>(
                                  source: colorOptions,
                                  value: (i, v) => i,
                                  label: (i, v) => v['name'],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.07),
                      AppButton(
                          name: 'S\'INSRIRE',
                          color: AppColors.primaryColor,
                          onTap: (){
                            if(formkey.currentState!.validate()){
                              showLoader("Inscription en cours\nVeuillez patienter...");
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
                                "gender": genreOptions[genreTag]['value'],
                                "cartype": carOptions[genreTag]['value'],
                                'carplate': carPlaqueController.text.toString(),
                                "colour": colorOptions[genreTag]['value'],
                                "longitude": 0.5,
                                "latitude": 0.5,
                                "online": false
                              };

                              Provider.of<Auth>(context, listen: false)
                                  .request(data: data).then((res){
                                disableLoader();
                                if(res['code'] == "OTP"){
                                  FirebaseFirestore.instance.collection('drivers')
                                      .doc(phoneController.text.trim()).set(data);
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => VerifyNumberScreen(
                                            phone: phoneController.text.trim(),
                                            register: true,
                                          )
                                      ),
                                          (route)=>false
                                  );
                                } else if(res['code'] == "NOK"){
                                  notification_dialog_auth(
                                      context,
                                      '${res['message']}',
                                      Icons.warning,
                                      Colors.yellow,
                                      {'label': 'FERMER', "onTap": (){
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CheckPage()
                                          ),
                                                (route)=>false
                                        );
                                      }},
                                      20,
                                      false);

                                } else if (res['code'] == "KO"){
                                  notification_dialog_auth(
                                      context,
                                      '${res['message']}',
                                      Icons.warning,
                                      Colors.yellow,
                                      {'label': 'FERMER', "onTap": (){
                                        Navigator.pop(context);
                                      }},
                                      20,
                                      false);
                                } else {
                                  notification_dialog_auth(
                                      context,
                                      'Une erreur s\'est produite.',
                                      Icons.warning,
                                      Colors.yellow,
                                      {'label': 'REESAYEZ', "onTap": (){
                                        Navigator.pop(context);
                                      }},
                                      20,
                                      false);
                                }
                              });
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
