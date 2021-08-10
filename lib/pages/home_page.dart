import 'package:eins_client/widgets/app_bar.dart';
import 'package:eins_client/widgets/bottom_navigation_bar.dart';
import 'package:eins_client/widgets/my_filter_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    print(MediaQuery.of(context).padding.bottom);

    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Builder(builder: (context) {
            return Container(
              width: mediaSize.width,
              height: mediaSize.height -
                  (Scaffold.of(context).appBarMaxHeight ?? 0.0) -
                  (68 + MediaQuery.of(context).padding.bottom),
              child: MyFilter(),
            );
          }),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar(context, controller, 0),
    );
  }
}
