import 'dart:math';

import 'package:eins_client/providers/sales_provider.dart';
import 'package:eins_client/screens/sales_web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalesItem extends StatefulWidget {
  const SalesItem({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  _SalesItemState createState() => _SalesItemState();
}

class _SalesItemState extends State<SalesItem> {
  late final PageController _controller;
  late int _currentPage;
  late bool _isInfoOpen;

  @override
  void initState() {
    super.initState();

    _controller = PageController();
    _currentPage = 0;
    _isInfoOpen = false;
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final SalesProvider salesProv = context.read<SalesProvider>();

    return Container(
      color: Colors.indigo[200],
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          Container(
            width: mediaSize.width,
            height: 200,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: salesProv.mainImageList[widget.index].length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return salesProv.mainImageList[widget.index][index];
                        },
                      ),
                    ),
                    Container(
                      width: 200,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                  iconSize: 50,
                                  color: Colors.indigo,
                                  icon: Icon(Icons.arrow_left),
                                  onPressed: () {
                                    _currentPage--;
                                    _controller.animateToPage(
                                      _currentPage,
                                      duration: Duration(milliseconds: 100),
                                      curve: Curves.easeIn,
                                    );
                                  },
                                ),
                                IconButton(
                                  iconSize: 50,
                                  color: Colors.indigo,
                                  icon: Icon(Icons.arrow_right),
                                  onPressed: () {
                                    _currentPage++;
                                    _controller.animateToPage(
                                      _currentPage,
                                      duration: Duration(milliseconds: 100),
                                      curve: Curves.easeIn,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(
                                salesProv.mainImageList[widget.index].length *
                                        2 -
                                    1, (index) {
                              if (index % 2 == 0) {
                                return Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index / 2 == _currentPage
                                        ? Colors.indigo
                                        : Colors.indigo[100],
                                  ),
                                );
                              } else {
                                return SizedBox(width: 10);
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Text(
                                salesProv.titleList[widget.index],
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[900]),
                              ),
                            ),
                            Text(
                              salesProv.subTitleList[widget.index],
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            SalesWebView.routeName,
                            arguments: salesProv.salesUrlList[widget.index],
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: Center(
                            child: Text(
                              "naver 구매",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _isInfoOpen ? salesProv.infoImageList[widget.index] : Container(),
          InkWell(
            onTap: () {
              setState(() {
                _isInfoOpen = !_isInfoOpen;
              });
            },
            child: Container(
              width: mediaSize.width,
              height: 30,
              color: Colors.indigo[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isInfoOpen ? "상품 정보 가리기" : "상품 정보 더보기",
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.0,
                    ),
                  ),
                  Transform.rotate(
                    angle: _isInfoOpen ? pi : 0,
                    child: Icon(
                      Icons.arrow_drop_down_circle_outlined,
                      size: 24,
                      color: Colors.indigo[900],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
