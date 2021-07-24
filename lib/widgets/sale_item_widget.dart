import 'package:eins_client/providers/sales_provider.dart';
import 'package:eins_client/screens/sales_web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SaleItem extends StatelessWidget {
  const SaleItem({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final SalesProvider salesProv = context.read<SalesProvider>();

    String cost = "";

    salesProv.costList[index]
        .toString()
        .split("")
        .reversed
        .toList()
        .asMap()
        .forEach((i, element) {
      if (i % 3 == 0 && i != 0)
        cost = element + "," + cost;
      else
        cost = element + cost;
    });

    String originalCost = "";

    salesProv.originalCostList[index]
        .toString()
        .split("")
        .reversed
        .toList()
        .asMap()
        .forEach((i, element) {
      if (i % 3 == 0 && i != 0)
        originalCost = element + "," + originalCost;
      else
        originalCost = element + originalCost;
    });

    return Container(
      width: (mediaSize.width - 80) / 2,
      height: (mediaSize.width - 80) / 2 * 8 / 5,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        border: Border.all(
          width: 2,
          color: Colors.deepPurple[300]!,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: (mediaSize.width - 80) / 2 - 44,
            height: (mediaSize.width - 80) / 2 - 44,
            child: salesProv.imageList[index],
          ),
          Expanded(
              child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  salesProv.titleList[index],
                  style:
                      TextStyle(fontSize: 12, color: Colors.black, height: 1),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      cost,
                      style: TextStyle(
                          color: Colors.black, fontSize: 14, height: 1),
                    ),
                    Text(
                      originalCost,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                SalesWebView.routeName,
                arguments: salesProv.salesUrlList[index],
              );
            },
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.deepPurple[300],
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      'assets/naver/naver.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "구매하기",
                    style:
                        TextStyle(color: Colors.white, fontSize: 18, height: 1),
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
