import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeProvider with ChangeNotifier {
  int? _length;
  int? _selectedIndex;
  List<String> _urlList = <String>[];
  List<String> _titleList = <String>[];
  List<Container> _youtubePlayerList = <Container>[];
  List<YoutubePlayerController> _youtubeControllerList =
      <YoutubePlayerController>[];

  int get length => _length ?? 0;
  int? get selectedIndex => _selectedIndex;
  List<String> get titleList => _titleList;
  List<Container?> get youtubePlayerList => _youtubePlayerList;

  Future<void> getYoutubeInfo() async {
    List<Container> tempPlayerList = <Container>[];
    List<YoutubePlayerController> tempControllerList =
        <YoutubePlayerController>[];
    List<String> tempUrlList = <String>[];
    List<String> tempTitleList = <String>[];

    try {
      final QuerySnapshot<Map<String, dynamic>> youtubeData =
          await youtubeRef.orderBy("order").get();

      youtubeData.docs.forEach((element) {
        Map<String, dynamic> e = element.data();

        tempUrlList.add(e["url"]);
        tempTitleList.add(e["title"]);
        tempPlayerList.add(Container());
        tempControllerList.add(YoutubePlayerController(initialVideoId: ""));
      });
    } catch (e) {
      rethrow;
    }

    _length = tempUrlList.length;
    _urlList = tempUrlList;
    _titleList = tempTitleList;
    _youtubePlayerList = tempPlayerList;
    _youtubeControllerList = tempControllerList;

    notifyListeners();
  }

  void initController(int index) {
    final GlobalKey playerKey = GlobalKey();
    final String? id = YoutubePlayer.convertUrlToId(_urlList[index]);

    if (id == null) {
      _youtubeControllerList[index] =
          YoutubePlayerController(initialVideoId: "");
      _youtubePlayerList[index] =
          Container(child: AspectRatio(aspectRatio: 16 / 9));

      throw Exception("receive wrong url");
    }

    _youtubeControllerList[index] = YoutubePlayerController(
      initialVideoId: id,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: false,
      ),
    );

    _youtubePlayerList[index] = Container(
      key: playerKey,
      child: WillPopScope(
        onWillPop: () async {
          final controller = _youtubeControllerList[index];

          if (controller.value.isFullScreen) {
            selectPlayer(index);

            return false;
          }
          return true;
        },
        child: YoutubePlayer(
          aspectRatio: 16 / 9,
          controller: _youtubeControllerList[index],
          showVideoProgressIndicator: true,
          bottomActions: [
            const SizedBox(width: 14.0),
            CurrentPosition(),
            const SizedBox(width: 8.0),
            ProgressBar(isExpanded: true),
            RemainingDuration(),
            IconButton(
              icon: Icon(
                _youtubeControllerList[index].value.isFullScreen
                    ? Icons.fullscreen_exit
                    : Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: () {
                selectPlayer(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void selectPlayer(int index) {
    if (!_youtubeControllerList[index].value.isPlaying) {
      for (int i = 0; i < _length!; i++) {
        if (_youtubeControllerList[i].value.isPlaying) {
          _youtubeControllerList[i].pause();
        }
      }
    }

    _selectedIndex = _selectedIndex == index ? null : index;

    _youtubeControllerList[index].toggleFullScreenMode();

    if (_selectedIndex == null) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }

    notifyListeners();
  }

  void disposeController(int index) {
    _youtubeControllerList[index].dispose();
  }
}
