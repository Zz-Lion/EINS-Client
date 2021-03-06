import 'dart:io';

import 'package:eins_client/constants/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SalesWebViewScreen extends StatefulWidget {
  static const String routeName = '/sales';

  const SalesWebViewScreen({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  _SalesWebViewScreenState createState() => _SalesWebViewScreenState();
}

class _SalesWebViewScreenState extends State<SalesWebViewScreen> {
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: kPrimaryColor),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
