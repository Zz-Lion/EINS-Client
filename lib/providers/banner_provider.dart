import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:transparent_image/transparent_image.dart';

class BannerProvider with ChangeNotifier {
  List<FadeInImage> _bannerImages = <FadeInImage>[];

  List<FadeInImage> get bannerImages => _bannerImages;

  Future<void> getBannerInfo() async {
    List<String> tempImageUrl = <String>[];
    List<FadeInImage> tempBannerImages = <FadeInImage>[];

    try {
      final DocumentSnapshot<Map<String, dynamic>> einsBanners =
          await adRef.doc("banners").get();

      tempImageUrl = List<String>.from(einsBanners.data()!["image_url"]);
      tempBannerImages = List<FadeInImage>.generate(
          tempImageUrl.length,
          (index) => FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: CachedNetworkImageProvider(tempImageUrl[index]),
                fit: BoxFit.fill,
              ));
    } catch (e) {}

    _bannerImages = tempBannerImages;
  }
}
