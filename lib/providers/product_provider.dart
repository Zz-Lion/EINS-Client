import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constants.dart';
import 'package:eins_client/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductProvider {
  int? _length;
  List<ProductModel> _productList = <ProductModel>[];
  List<CachedNetworkImage> _productImageList = <CachedNetworkImage>[];
  List<CachedNetworkImage> _descImageList = <CachedNetworkImage>[];

  int get length => _length ?? 0;
  List<ProductModel> get productList => _productList;
  List<CachedNetworkImage> get productImageList => _productImageList;
  List<CachedNetworkImage> get descImageList => _descImageList;

  Future<void> getProductInfo() async {
    List<ProductModel> tempProducts = <ProductModel>[];
    List<CachedNetworkImage> tempImages = <CachedNetworkImage>[];
    List<CachedNetworkImage> tempDescImages = <CachedNetworkImage>[];

    try {
      final QuerySnapshot<Map<String, dynamic>> productsData =
          await productsRef.orderBy("release_date", descending: true).get();

      productsData.docs.forEach((element) {
        Map<String, dynamic> e = element.data();

        tempProducts.add(ProductModel.fromDoc(element));
        tempImages.add(CachedNetworkImage(
            imageUrl: e["image_url"] as String, fit: BoxFit.fitHeight));
        tempDescImages.add(CachedNetworkImage(
            imageUrl: e["desc_image_url"] as String, fit: BoxFit.fill));
      });
    } catch (e) {
      rethrow;
    }

    _productList = tempProducts;
    _productImageList = tempImages;
    _descImageList = tempDescImages;
    _length = tempProducts.length;
  }

  CachedNetworkImage? productImageByName(String productName) {
    for (int i = 0; i < (_length ?? 0); i++) {
      if (_productList[i].productName == productName) {
        return _productImageList[i];
      }
    }
  }

  List<double>? productDefaultDurationByName(String productName) {
    for (int i = 0; i < (_length ?? 0); i++) {
      if (_productList[i].productName == productName) {
        return _productList[i].defaultDuration;
      }
    }
  }
}
