import 'package:eins_client/constants/color_constant.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget appBar() {
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    title: Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Image.asset(
        'assets/images/EINS.png',
        color: kPrimaryColor,
        height: 24,
        fit: BoxFit.fitHeight,
      ),
    ),
  );
}
