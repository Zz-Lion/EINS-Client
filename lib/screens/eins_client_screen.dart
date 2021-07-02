import 'package:eins_client/pages/customer_page.dart';
import 'package:eins_client/pages/home_page.dart';
import 'package:eins_client/pages/info_page.dart';
import 'package:eins_client/pages/sales_page.dart';
import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    context.read<LocalStorageProvider>().disposeLocalStorage();

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
