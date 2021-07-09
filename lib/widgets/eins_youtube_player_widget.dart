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
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Colors.deepPurple[300]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
            child: Container(
              width: mediaSize.width - 20,
              child: Text(
                "${youtubeProv.titleList[index]}",
                style: TextStyle(color: Colors.white, fontSize: 24, height: 1),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: youtubeProv.youtubePlayerList[index]),
        ],
      ),
    );
  }
}
