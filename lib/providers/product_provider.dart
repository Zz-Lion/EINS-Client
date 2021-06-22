import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constants.dart';
import 'package:eins_client/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  int? _length;
  Map<String, Product> _products = <String, Product>{};
  Map<String, Image> _productImages = <String, Image>{};

  int get length => _length ?? 0;
  Map<String, Product> get products => _products;
  Map<String, Image> get productImages => _productImages;

  Future<void> getProductInfo() async {
    Map<String, Product> tempProducts = Map<String, Product>();
    Map<String, Image> tempImages = Map<String, Image>();
    try {
      QuerySnapshot<Map<String, dynamic>> productsData =
          await productsRef.get();

      productsData.docs.forEach((element) {
        Map<String, dynamic> e = element.data();

        tempProducts[e["product_name"] as String] = Product.fromDoc(element);
        tempImages[e["product_name"] as String] =
            Image.network(e["image_url"] as String, fit: BoxFit.fitHeight);
      });
    } catch (e) {
      rethrow;
    }

    _products = tempProducts;
    _productImages = tempImages;
  }
}
