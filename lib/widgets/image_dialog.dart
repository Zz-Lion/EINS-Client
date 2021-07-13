import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Future<void> imageDialog(BuildContext context, CachedNetworkImage image) async {
  showDialog(
      context: context,
      builder: (context) => Dialog(
            child: Stack(
              children: <Widget>[
                Container(
                  width: 280,
                  height: 420,
                  child: image,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 30,
                      )),
                ),
              ],
            ),
          ));
}
