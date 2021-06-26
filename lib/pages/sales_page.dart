import 'package:eins_client/providers/sales_provider.dart';
import 'package:eins_client/widgets/app_bar.dart';
import 'package:eins_client/widgets/sales_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: appBar(controller),
      body: SafeArea(
        child: Builder(builder: (context) {
          return Container(
            width: mediaSize.width,
            height: mediaSize.height -
                (Scaffold.of(context).appBarMaxHeight ?? 0.0),
            color: Colors.indigo[100],
            child: ListView.builder(
              itemCount: context.read<SalesProvider>().length,
              itemBuilder: (context, index) => SalesItem(index: index),
            ),
          );
        }),
      ),
    );
  }
}
