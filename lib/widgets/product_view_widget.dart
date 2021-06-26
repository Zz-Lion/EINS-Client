import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProductView extends StatelessWidget {
  const ProductView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final ProductProvider productProv = context.read<ProductProvider>();

    return Container(
      color: Colors.indigo[200],
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Container(
              width: mediaSize.width - 20,
              child: Text(
                "아인스 필터 소개",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: mediaSize.width,
            height: 225,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              itemCount: productProv.length,
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: (225 / 375),
                mainAxisExtent: 375,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: DottedDecoration(
                    color: Colors.grey,
                    linePosition: LinePosition.right,
                    dash: const <int>[5, 5],
                    strokeWidth: 5,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 150,
                        height: 225,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: productProv.productImageList[index],
                        ),
                      ),
                      Container(
                        width: 220,
                        height: 225,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Text(
                                productProv.productList[index].productName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[900],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "용도",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      productProv.productList[index].usage,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "권장사용기간",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      productProv
                                          .productList[index].recommendedPeriod,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    productProv.productList[index]
                                                .certification !=
                                            null
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "취득인증",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                productProv.productList[index]
                                                    .certification!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    productProv.productList[index]
                                                .performence !=
                                            null
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "성능",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                productProv.productList[index]
                                                    .performence!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
