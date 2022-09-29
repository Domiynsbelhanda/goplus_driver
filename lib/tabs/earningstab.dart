import 'package:taxigo_driver/brand_colors.dart';
import 'package:taxigo_driver/dataprovider.dart';
import 'package:taxigo_driver/screens/historypage.dart';
import 'package:taxigo_driver/widgets/BrandDivier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> HistoryPage()));
          },

          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Image.asset('images/taxi.png', width: 70,),
                  SizedBox(width: 16,),
                  Text('Trips', style: TextStyle(fontSize: 16), ),
                  Expanded(child: Container(child: Text(Provider.of<AppData>(context).tripCount.toString(), textAlign: TextAlign.end, style: TextStyle(fontSize: 18),))),
                ],
              ),
            ),
          ),

        ),

        BrandDivider(),

      ],
    );
  }
}
