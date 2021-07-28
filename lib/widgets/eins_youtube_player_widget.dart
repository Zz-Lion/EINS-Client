import 'package:eins_client/constants/color_constant.dart';
import 'package:eins_client/providers/youtube_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EinsYoutubePlayer extends StatelessWidget {
  const EinsYoutubePlayer({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final YoutubeProvider youtubeProv = context.read<YoutubeProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: kPrimaryColor),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 5,
                  height: 24,
                  color: kBackgroundColor,
                ),
                const SizedBox(width: 5),
                Container(
                  width: mediaSize.width - 90,
                  child: Text(
                    "${youtubeProv.titleList[index]}",
                    style: TextStyle(
                        color: kBackgroundColor, fontSize: 20, height: 1),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: youtubeProv.youtubePlayerList[index],
            ),
          ),
        ],
      ),
    );
  }
}
