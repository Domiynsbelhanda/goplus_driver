import 'package:flutter/material.dart';
import 'package:goplus_driver/main.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:toast/toast.dart';
import '../utils/app_colors.dart';
import '../utils/class_builder.dart';
import '../utils/global_variables.dart';
import 'AboutPage.dart';
import 'HistoryPage.dart';
import 'bodyPage.dart';

class HomePage extends StatefulWidget{
  HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> with TickerProviderStateMixin{

  late KFDrawerController _drawerController;
  late Size size;

  @override
  void initState() {
    super.initState();
    _drawerController = KFDrawerController(
      initialPage: ClassBuilder.fromString('BodyPage'),
      items: [
        KFDrawerItem.initWithPage(
          text: const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
                'Accueil',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0
                )
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(bottom : 16.0, left: 8.0),
            child: Icon(
              Icons.home,
              color: Colors.white,
              size: 24.0,
            ),
          ),
          page: BodyPage(),
        ),

        KFDrawerItem.initWithPage(
          text: const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
                'Historique',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24
                )
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(bottom : 16.0, left: 8.0),
            child: Icon(
              Icons.list_alt,
              color: Colors.white,
              size: 24,
            ),
          ),
          page: HistoryPage(),
        ),

        KFDrawerItem.initWithPage(
          text: const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
                'APropos',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0
                )
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(bottom : 16.0, left: 8.0),
            child: Icon(
              Icons.settings,
              color: Colors.white,
              size: 24.0,
            ),
          ),
          page: AboutPage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    ToastContext().init(context);
    readBitconMarkerPinner();
    return Scaffold(
      body: KFDrawer(
        borderRadius: 16.0,
        shadowBorderRadius: 16.0,
        menuPadding: const EdgeInsets.all(8.0),
        scrollable: true,
        controller: _drawerController,
        header: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 64.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              width: MediaQuery.of(context).size.width * 0.6,
              child: Image.asset(
                'assets/icon/white-text.png',
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ),
        footer: KFDrawerItem(
          text: const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
                'Deconnexion',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0
                )
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(bottom : 16.0, left: 8.0),
            child: Icon(
              Icons.logout,
              color: Colors.white,
              size: 24.0,
            ),
          ),
          onPressed: () {
            logOut();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => MyApp()
                ),
                    (Route<dynamic> route) => false
            );
          },
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange, AppColors.primaryColor],
            tileMode: TileMode.repeated,
          ),
        ),
      )
    );
  }
}