import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constants.dart';
import 'package:eins_client/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  int? _length;
  List<ProductModel> _productList = <ProductModel>[];
  List<CachedNetworkImage> _productImageList = <CachedNetworkImage>[];

  int get length => _length ?? 0;
  List<ProductModel> get productList => _productList;
  List<CachedNetworkImage> get productImageList => _productImageList;

  Future<void> getProductInfo() async {
    List<ProductModel> tempProducts = <ProductModel>[];
    List<CachedNetworkImage> tempImages = <CachedNetworkImage>[];
    try {
      final QuerySnapshot<Map<String, dynamic>> productsData =
          await productsRef.orderBy("release_date", descending: true).get();

      productsData.docs.forEach((element) {
        Map<String, dynamic> e = element.data();

        tempProducts.add(ProductModel.fromDoc(element));
        tempImages.add(CachedNetworkImage(
            imageUrl: e["image_url"] as String, fit: BoxFit.fitHeight));
      });
    } catch (e) {
      rethrow;
    }

    _productList = tempProducts;
    _productImageList = tempImages;
    _length = tempProducts.length;
  }

  CachedNetworkImage? productImageByName(String productName) {
    for (int i = 0; i < (_length ?? 0); i++) {
      if (_productList[i].productName == productName) {
        return _productImageList[i];
      }
    }
  }
}
