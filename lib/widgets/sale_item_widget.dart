import 'package:eins_client/constants/color_constant.dart';
import 'package:eins_client/providers/sales_provider.dart';
import 'package:eins_client/screens/sales_web_view_screen.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SaleItem extends StatelessWidget {
  const SaleItem({Key? key, required this.index}) : super(key: key);

  final int index;

  Future<void> _launchInBrowser(BuildContext context, String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: false,
          forceWebView: false,
        );
      } else {
        throw "$url을 실행할 수 없습니다.";
      }
    } catch (e) {
      errorDialog(context, e);
    }
  }

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

    return Column(
      children: <Widget>[
        Container(
          width: mediaSize.width - 40,
          height: 144,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(
              width: 2,
              color: kPrimaryColor.withOpacity(0.6),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                child: salesProv.imageList[index],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      salesProv.titleList[index],
                      style: TextStyle(
                          fontSize: 18,
                          color: kPrimaryColor,
                          height: 1,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Text(
                      salesProv.subTitleList[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: kPrimaryColor,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(flex: 2),
                    Row(
                      children: <Widget>[
                        Text(
                          originalCost,
                          style: TextStyle(
                            color: kPrimaryColor.withOpacity(0.6),
                            fontSize: 14,
                            height: 1,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          cost,
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 14,
                            height: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  SalesWebView.routeName,
                  arguments: salesProv.salesUrlList[index],
                );
              },
              child: Container(
                height: 40,
                width: (mediaSize.width - 40) / 2 - 40,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: Center(
                  child: Text(
                    "바로 구매",
                    style: TextStyle(
                      color: kBackgroundColor,
                      fontSize: 16,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _launchInBrowser(context, salesProv.salesUrlList[index]);
              },
              child: Container(
                height: 40,
                width: (mediaSize.width - 40) / 2 - 40,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  border: Border.all(
                    width: 2,
                    color: kPrimaryColor.withOpacity(0.6),
                  ),
                ),
                child: Center(
                  child: Text(
                    "포탈 접속",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 16,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
