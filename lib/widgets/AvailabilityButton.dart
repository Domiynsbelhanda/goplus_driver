import 'package:flutter/material.dart';

class AvailabilityButton extends StatelessWidget {

  final String title;
  final Color color;
  final Function onPressed;

  AvailabilityButton({this.title, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(5)
      ),
      color: color,
      textColor: Colors.white,
      child: Container(
        height: MediaQuery.of(context).size.width / 7,
        width: MediaQuery.of(context).size.width / 2,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 17, fontFamily: 'Brand-Bold'),
          ),
        ),
      ),
    );
  }
}
