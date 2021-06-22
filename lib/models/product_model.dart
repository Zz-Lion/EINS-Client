import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productName;
  final String imageUrl;
  final DateTime releaseDate;
  final String usage;
  final String recommendedPeriod;
  final String? certification;
  final String? performence;

  Product({
    required this.productName,
    required this.imageUrl,
    required this.releaseDate,
    required this.usage,
    required this.recommendedPeriod,
    this.certification,
    this.performence,
  });

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> productDoc) {
    final Map<String, dynamic> productData =
        Map<String, dynamic>.from(productDoc.data()!);

    return Product(
      productName: productData["product_name"] as String,
      imageUrl: productData["image_url"] as String,
      releaseDate: (productData["release_date"] as Timestamp).toDate(),
      usage: productData["usage"] as String,
      recommendedPeriod: productData["recommended_period"] as String,
      certification: productData["certification"] != null
          ? productData["certification"] as String
          : null,
      performence: productData["performence"] != null
          ? productData["performence"] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = <String, dynamic>{};
    m["product_name"] = productName;
    m["image_url"] = imageUrl;
    m["release_date"] = releaseDate;
    m["usage"] = usage;
    m["recommended_period"] = recommendedPeriod;
    m["certification"] = certification ?? null;
    m["performence"] = performence ?? null;

    return m;
  }

  Product copyWith({
    productName,
    imageUrl,
    purchaseLink,
    releaseDate,
    price,
    usage,
    recommendedPeriod,
    certification,
    performence,
  }) {
    return Product(
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      usage: usage ?? this.usage,
      recommendedPeriod: recommendedPeriod ?? this.recommendedPeriod,
      certification: certification ?? this.certification,
      performence: performence ?? this.performence,
    );
  }
}
