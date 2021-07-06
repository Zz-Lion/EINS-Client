import 'package:cloud_firestore/cloud_firestore.dart';

class FilterModel {
  final String id;
  final String productName;
  final DateTime startDate;
  final DateTime replaceDate;
  final String desc;

  FilterModel({
    required this.id,
    required this.productName,
    required this.startDate,
    required this.replaceDate,
    required this.desc,
  });

  factory FilterModel.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> filterDoc) {
    final Map<String, dynamic> filterData =
        Map<String, dynamic>.from(filterDoc.data()!);

    return FilterModel(
      id: filterDoc.id,
      productName: filterData["product_name"] as String,
      startDate: (filterData["start_date"] as Timestamp).toDate(),
      replaceDate: (filterData["replace_date"] as Timestamp).toDate(),
      desc: filterData["desc"] as String,
    );
  }

  Map<String, dynamic> toDoc() {
    Map<String, dynamic> m = <String, dynamic>{};

    m["id"] = id;
    m["product_name"] = productName;
    m["start_date"] = Timestamp.fromDate(startDate);
    m["replace_date"] = Timestamp.fromDate(replaceDate);
    m["desc"] = desc;

    return m;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = <String, dynamic>{};

    m["id"] = id;
    m["product_name"] = productName;
    m["start_date"] = startDate.toString();
    m["replace_date"] = replaceDate.toString();
    m["desc"] = desc;

    return m;
  }

  FilterModel copyWith(
      {id, productName, defaultDuration, startDate, replaceDate, desc}) {
    return FilterModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      startDate: startDate ?? this.startDate,
      replaceDate: replaceDate ?? this.replaceDate,
      desc: desc ?? this.desc,
    );
  }
}
