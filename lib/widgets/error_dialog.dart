import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/color_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void errorDialog(BuildContext context, dynamic e,
    {void Function(dynamic)? afterDialog}) {
  late String errorTitle;
  late String errorPlugin;
  late String errorMessage;

  if (e is FirebaseException) {
    errorTitle = e.code;
    errorMessage = e.message ?? "firebase exception";
    errorPlugin = e.plugin;
  } else {
    errorTitle = "오류";
    errorPlugin = "flutter_error/eins_error";
    errorMessage = e.toString();
  }

  if (Platform.isIOS) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(errorTitle),
            content: Text(errorPlugin + "\n" + errorMessage),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("확인", style: TextStyle(color: kPrimaryColor)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      ).then(afterDialog ?? (_) {});
    });
  } else {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(errorTitle),
            content: Text(
              errorPlugin + "\n" + errorMessage,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("확인", style: TextStyle(color: kPrimaryColor)),
              ),
            ],
          );
        },
      ).then(afterDialog ?? (_) {});
    });
  }
}
