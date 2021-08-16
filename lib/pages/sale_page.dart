import 'package:eins_client/providers/sales_provider.dart';
import 'package:eins_client/widgets/app_bar.dart';
import 'package:eins_client/widgets/bottom_navigation_bar.dart';
import 'package:eins_client/widgets/sale_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalePage extends StatelessWidget {
  const SalePage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: Builder(builder: (context) {
          return Container(
            width: mediaSize.width,
            height: mediaSize.height -
                (Scaffold.of(context).appBarMaxHeight ?? 0.0) -
                (68 + MediaQuery.of(context).padding.bottom),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              scrollDirection: Axis.vertical,
              itemCount: context.read<SalesProvider>().length,
              itemBuilder: (context, index) => SaleItem(index: index),
              separatorBuilder: (_, __) => const SizedBox(height: 20),
            ),
          );
        }),
      ),
      bottomNavigationBar: Container(
          color: Colors.grey[300],
          child: bottomNavigationBar(context, controller, 2)),
    );
  }
}
