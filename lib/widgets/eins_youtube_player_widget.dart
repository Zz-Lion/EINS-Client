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
      color: Colors.indigo[200],
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Container(
              width: mediaSize.width - 20,
              child: Text(
                "${youtubeProv.titleList[index]}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: youtubeProv.youtubePlayerList[index]),
        ],
      ),
    );
  }
}
