import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eins_client/pages/customer_page.dart';
import 'package:eins_client/pages/home_page.dart';
import 'package:eins_client/pages/info_page.dart';
import 'package:eins_client/pages/sales_page.dart';
import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EinsClient extends StatefulWidget {
  static const String routeName = '/home';

  const EinsClient({
    Key? key,
  }) : super(key: key);

  @override
  _EinsClientState createState() => _EinsClientState();
}

class _EinsClientState extends State<EinsClient> {
  late PageController _pageController;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        errorDialog(
            context, Exception("와이파이, 모바일 데이터 혹은 비행기모드 설정을 확인해 주시기 바랍니다."),
            afterDialog: (value) {
          SystemChannels.platform.invokeMethod("SystemNavigator.pop");
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    context.read<LocalStorageProvider>().disposeLocalStorage();
    _connectivitySubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        HomePage(controller: _pageController),
        InfoPage(controller: _pageController),
        SalesPage(controller: _pageController),
        CustomerPage(controller: _pageController),
      ],
    );
  }
}
