import 'package:taxigo_driver/brand_colors.dart';
import 'package:taxigo_driver/globalvariabels.dart';
import 'package:taxigo_driver/tabs/earningstab.dart';
import 'package:taxigo_driver/tabs/hometab.dart';
import 'package:taxigo_driver/tabs/profiletab.dart';
import 'package:taxigo_driver/tabs/ratingstab.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../translations.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {

  TabController tabController;
  int selecetdIndex = 0;

  void onItemClicked(int index){
    setState(() {
      selecetdIndex = index;
      tabController.index = selecetdIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: <Widget>[
          HomeTab(),
          EarningsTab(),
          //RatingsTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text(Translations.of(context).text('home')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            title: Text(Translations.of(context).text('earning')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text(Translations.of(context).text('about')),
          ),
        ],
        currentIndex: selecetdIndex,
        unselectedItemColor: BrandColors.colorIcon,
        selectedItemColor: BrandColors.colorOrange,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
      ),
    );
  }
}
