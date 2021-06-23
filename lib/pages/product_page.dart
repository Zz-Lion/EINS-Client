import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
          child: Image.asset(
            'assets/images/EINS.jpg',
            height: 40,
            fit: BoxFit.fitHeight,
          ),
        ),
        bottom: TabBar(
          onTap: (index) {
            controller.jumpToPage(index);
          },
          tabs: [
            Tab(
              child: Text(
                "홈",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Text(
                "필터정보",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Text(
                "구매하기",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Text(
                "고객센터",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
