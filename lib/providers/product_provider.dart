import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constants.dart';
import 'package:eins_client/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  int? _length;
  Map<String, Product> _products = <String, Product>{};
  Map<String, CachedNetworkImage> _productImages =
      <String, CachedNetworkImage>{};

  int get length => _length ?? 0;
  Map<String, Product> get products => _products;
  Map<String, CachedNetworkImage> get productImages => _productImages;

  Future<void> getProductInfo() async {
    Map<String, Product> tempProducts = Map<String, Product>();
    Map<String, CachedNetworkImage> tempImages =
        Map<String, CachedNetworkImage>();
    try {
      final QuerySnapshot<Map<String, dynamic>> productsData =
          await productsRef.get();

      productsData.docs.forEach((element) {
        Map<String, dynamic> e = element.data();

        tempProducts[e["product_name"] as String] = Product.fromDoc(element);
        tempImages[e["product_name"] as String] = CachedNetworkImage(
            imageUrl: e["image_url"] as String, fit: BoxFit.fitHeight);
      });
    } catch (e) {
      rethrow;
    }

    _products = tempProducts;
    _productImages = tempImages;
  }
}
