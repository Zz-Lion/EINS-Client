import 'package:flutter/material.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
          child: Image.asset(
            'assets/images/EINS.jpg',
            height: 24,
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
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Tab(
              child: Text(
                "필터정보",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Tab(
              child: Text(
                "구매하기",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Tab(
              child: Text(
                "고객센터",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
