import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productName;
  final String imageUrl;
  final DateTime releaseDate;
  final List<double> defaultDuration;
  final String descImageUrl;

  ProductModel({
    required this.productName,
    required this.imageUrl,
    required this.releaseDate,
    required this.defaultDuration,
    required this.descImageUrl,
  });

  factory ProductModel.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> productDoc) {
    final Map<String, dynamic> productData =
        Map<String, dynamic>.from(productDoc.data()!);

    return ProductModel(
      productName: productData["product_name"] as String,
      imageUrl: productData["image_url"] as String,
      releaseDate: (productData["release_date"] as Timestamp).toDate(),
      defaultDuration: List<num>.from(productData["default_duration"])
          .map((e) => e.toDouble())
          .toList(),
      descImageUrl: productData["desc_image_url"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = <String, dynamic>{};
    m["product_name"] = productName;
    m["image_url"] = imageUrl;
    m["release_date"] = releaseDate;
    m["default_duration"] = defaultDuration;
    m["desc_image_url"] = descImageUrl;

    return m;
  }

  ProductModel copyWith({
    productName,
    imageUrl,
    purchaseLink,
    releaseDate,
    price,
    usage,
    recommendedPeriod,
    certification,
    performence,
    defaultDuration,
    descImageUrl,
  }) {
    return ProductModel(
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      descImageUrl: descImageUrl ?? this.descImageUrl,
    );
  }
}
