import 'package:goplus_driver/brand_colors.dart';
import 'package:flutter/material.dart';

class TaxiOutlineButton extends StatelessWidget {

  final String? title;
  final Function? onPressed;
  final Color? color;

  TaxiOutlineButton({this.title, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: ()=>onPressed!,
        child: Container(
          height: 50.0,
          child: Center(
            child: Text(title!,
                style: TextStyle(fontSize: 15.0, fontFamily: 'Brand-Bold', color: BrandColors.colorText)),
          ),
        )
    );
  }
}


