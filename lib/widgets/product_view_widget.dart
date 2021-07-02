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
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 5),
            child: Container(
              width: mediaSize.width - 20,
              child: Text(
                "아인스 필터 소개",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            width: mediaSize.width,
            height: 180,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: productProv.length,
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: (180 / 120),
                mainAxisExtent: 120,
              ),
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.deepPurple[100]),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: productProv.productImageList[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
