import 'package:flutter/material.dart';
import 'package:we_invited/utils/colors.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: MColors.primaryWhiteSmoke,
      child: Center(
        child: Container(
          height: 30.0,
          child: Image.asset("assets/splash_page_logo.png"),
        ),
      ),
    );
  }
}
