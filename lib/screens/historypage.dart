import 'package:taxigo_driver/brand_colors.dart';
import 'package:taxigo_driver/dataprovider.dart';
import 'package:taxigo_driver/widgets/BrandDivier.dart';
import 'package:taxigo_driver/widgets/HistoryTile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('trip_history')),
        backgroundColor: BrandColors.colorPrimary,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
          itemBuilder: (context, index) {
          return HistoryTile(
            history: Provider.of<AppData>(context).tripHistory[index],
          );
          },
          separatorBuilder: (BuildContext context, int index) => BrandDivider(),
          itemCount: Provider.of<AppData>(context).tripHistory.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap:  true,
      ),
    );
  }
}
