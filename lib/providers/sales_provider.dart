import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constant.dart';
import 'package:flutter/cupertino.dart';

class SalesProvider {
  int? _length;
  List<String> _salesUrlList = <String>[];
  List<String> _titleList = <String>[];
  List<String> _subTitleList = <String>[];
  List<int> _costList = <int>[];
  List<int> _originalCostList = <int>[];
  List<CachedNetworkImage> _imageList = <CachedNetworkImage>[];

  int get length => _length ?? 0;
  List<String> get salesUrlList => _salesUrlList;
  List<String> get titleList => _titleList;
  List<String> get subTitleList => _subTitleList;
  List<int> get costList => _costList;
  List<int> get originalCostList => _originalCostList;
  List<CachedNetworkImage> get imageList => _imageList;

  Future<void> getSalesInfo() async {
    List<String> tempSalesUrlList = <String>[];
    List<String> tempTitleList = <String>[];
    List<String> tempSubTitleList = <String>[];
    List<int> tempCostList = <int>[];
    List<int> tempOriginalCostList = <int>[];
    List<CachedNetworkImage> tempImageList = <CachedNetworkImage>[];

    try {
      final DocumentSnapshot<Map<String, dynamic>> einsSales =
          await adRef.doc("sales").get();

      tempSalesUrlList = List<String>.from(einsSales.data()!["sales_url"]);
      tempTitleList = List<String>.from(einsSales.data()!["title"]);
      tempSubTitleList = List<String>.from(einsSales.data()!["sub_title"]);
      tempCostList = List<int>.from(einsSales.data()!["cost"]);
      tempOriginalCostList = List<int>.from(einsSales.data()!["original_cost"]);
      tempImageList = List<CachedNetworkImage>.from(
          List<String>.from(einsSales.data()!["image_url"])
              .map((e) => CachedNetworkImage(
                    imageUrl: e,
                    fit: BoxFit.fill,
                  )));
    } catch (e) {
      throw "판매정보를 불러오지 못 하였습니다.";
    }

    _length = tempSalesUrlList.length;
    _salesUrlList = tempSalesUrlList;
    _titleList = tempTitleList;
    _subTitleList = tempSubTitleList;
    _costList = tempCostList;
    _originalCostList = tempOriginalCostList;
    _imageList = tempImageList;
  }
}
