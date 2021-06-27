import 'package:flutter/material.dart';

PreferredSizeWidget? appBar(PageController controller) {
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    title: Center(
      child: Image.asset(
        'assets/images/EINS.png',
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
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        Tab(
          child: Text(
            "필터정보",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        Tab(
          child: Text(
            "구매하기",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        Tab(
          child: Text(
            "고객센터",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
