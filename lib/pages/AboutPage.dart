import 'package:flutter/material.dart';
import 'package:kf_drawer/kf_drawer.dart';
import 'package:toast/toast.dart';
import '../utils/app_colors.dart';

class AboutPage extends KFDrawerContent {
  AboutPage({
    Key? key
  });
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AboutPage();
  }
}

class _AboutPage extends State<AboutPage>{

  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    ToastContext().init(context);

    return Stack(
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(48.0)
                  ),
                  child: IconButton(
                    onPressed: widget.onMenuPressed,
                    icon: const Icon(
                      Icons.menu,
                    ),
                  ),
                ),
              ),
            ),

            const Align(
              alignment: Alignment.center,
              child: Text(
                'About page'
              ),
            )
          ],
        ),
      ],
    );
  }
}