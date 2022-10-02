import 'package:flutter/material.dart';
import 'package:goplus_driver/utils/app_colors.dart';

notification_dialog(
    BuildContext context,
    var onTap,
    String text,
    IconData? icons,
    Color? color,
    double? fontSize,
    bool? barriere) {

  double width = MediaQuery.of(context).size.width;

  // show the dialog
  showDialog(
    context: context,
    barrierDismissible: barriere!,
    builder: (BuildContext contexts) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20.0)),
        child: SizedBox(
          width: width / 1,
          height: width / 1.1,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  children : [
                    Icon(
                      icons,
                      color: color,
                      size: width / 5,
                    ),

                    SizedBox(height: 16.0),

                    Container(
                      width : width / 1.5,
                      child: Text(
                          '${text}',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.black,
                          )
                      ),
                    ),

                    SizedBox(height: 16.0),

                    TextButton(
                      child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8.0)
                          ),
                          child: Text(
                            'FERMER',
                            style: TextStyle(
                                color: Colors.black
                            ),
                          )
                      ),
                      onPressed: ()=>onTap,
                    )
                  ]
              )
          ),
        ),
      );
    },
  );
}