import 'package:eins_client/providers/youtube_provider.dart';
import 'package:eins_client/widgets/eins_youtube_player_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with AutomaticKeepAliveClientMixin {
  late YoutubeProvider _youtubeProv;

  @override
  void initState() {
    super.initState();

    _youtubeProv = Provider.of<YoutubeProvider>(context, listen: false);
    for (int i = 0; i < _youtubeProv.length; i++) {
      _youtubeProv.initController(i);
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _youtubeProv.length; i++) {
      _youtubeProv.disposeController(i);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Size mediaSize = MediaQuery.of(context).size;
    final YoutubeProvider youtubeProv =
        Provider.of<YoutubeProvider>(context, listen: false);
    final List<Widget> youtubePlayerList = List<Widget>.generate(
        youtubeProv.length, (index) => EinsYoutubePlayer(index: index));

    final Widget defaultWidget = Builder(
        builder: (context) => Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Center(
                  child: Image.asset(
                    'assets/images/EINS.jpg',
                    height: 24,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                bottom: TabBar(
                  onTap: (index) {
                    widget.controller.jumpToPage(index);
                  },
                  tabs: [
                    Tab(
                      child: Text(
                        "홈",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "필터정보",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "구매하기",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "고객센터",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
              ),
              body: Builder(builder: (context) {
                return Container(
                  height: mediaSize.height -
                      (Scaffold.of(context).appBarMaxHeight ?? 0.0),
                  width: mediaSize.width,
                  color: Colors.indigo[100],
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Column(
                          children: youtubePlayerList,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            )).build(context);

    return OrientationBuilder(builder: (context, orientation) {
      final ScrollController scrollController = ScrollController(
        initialScrollOffset:
            (youtubeProv.selectedIndex ?? 0) * mediaSize.height,
      );

      return orientation == Orientation.portrait
          ? defaultWidget
          : ListView.builder(
              controller: scrollController,
              itemCount: youtubeProv.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  width: mediaSize.width,
                  height: mediaSize.height,
                  child: youtubeProv.youtubePlayerList[index]!,
                );
              },
            );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
