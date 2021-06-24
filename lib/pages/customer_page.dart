import 'package:eins_client/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(controller),
    );
  }
}
