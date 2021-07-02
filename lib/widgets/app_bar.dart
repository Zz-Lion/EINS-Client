import 'package:flutter/material.dart';

PreferredSizeWidget appBar() {
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    title: Center(
      child: Image.asset(
        'assets/images/EINS.png',
        height: 40,
        fit: BoxFit.fitHeight,
      ),
    ),
  );
}
