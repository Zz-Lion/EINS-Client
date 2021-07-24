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
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: (5 / 8),
                mainAxisExtent: (mediaSize.width - 80) / 2 * 8 / 5,
              ),
              itemCount: context.read<SalesProvider>().length,
              itemBuilder: (context, index) => SaleItem(index: index),
            ),
          );
        }),
      ),
      bottomNavigationBar: bottomNavigationBar(context, controller, 2),
    );
  }
}
