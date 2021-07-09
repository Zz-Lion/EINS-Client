import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SalesWebView extends StatefulWidget {
  static const String routeName = '/sales';

  const SalesWebView({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  _SalesWebViewState createState() => _SalesWebViewState();
}

class _SalesWebViewState extends State<SalesWebView> {
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
          children: [
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
                      shape: BoxShape.circle, color: Colors.deepPurple),
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
