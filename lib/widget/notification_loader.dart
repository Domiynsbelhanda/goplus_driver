import 'package:flutter/material.dart';

notification_loader(
    BuildContext context,
    var function) {

  // show the dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LoadingWidget();
    },
  );
}