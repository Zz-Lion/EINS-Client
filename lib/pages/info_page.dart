import 'package:eins_client/providers/youtube_provider.dart';
import 'package:eins_client/widgets/app_bar.dart';
import 'package:eins_client/widgets/eins_youtube_player_widget.dart';
import 'package:eins_client/widgets/product_view_widget.dart';
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
  late final YoutubeProvider _youtubeProv;
  late final List<Widget> youtubePlayerList;
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _youtubeProv = context.read<YoutubeProvider>();
    for (int i = 0; i < _youtubeProv.length; i++) {
      try {
        _youtubeProv.initController(i);
      } catch (e) {}
    }

    youtubePlayerList = List<Widget>.generate(
        _youtubeProv.length, (index) => EinsYoutubePlayer(index: index));
  }

  @override
  void dispose() {
    for (int i = 0; i < _youtubeProv.length; i++) {
      _youtubeProv.disposeController(i);
    }

    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Size mediaSize = MediaQuery.of(context).size;

    final Widget defaultWidget = Builder(
        builder: (context) => Scaffold(
              appBar: appBar(widget.controller),
              body: SafeArea(
                child: Builder(builder: (context) {
                  _scrollController =
                      ScrollController(initialScrollOffset: _scrollOffset);

                  return SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      color: Colors.indigo[100],
                      child: Column(
                        children: <Widget>[
                          ProductView(),
                          Column(
                            children: youtubePlayerList,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            )).build(context);

    return OrientationBuilder(builder: (context, orientation) {
      final ScrollController scrollController = ScrollController(
        initialScrollOffset:
            (_youtubeProv.selectedIndex ?? 0) * mediaSize.height,
      );

      if (orientation == Orientation.portrait) {
        return defaultWidget;
      } else {
        _scrollOffset = _scrollController.offset;
        _scrollController.dispose();

        return ListView.builder(
          controller: scrollController,
          itemCount: _youtubeProv.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              width: mediaSize.width,
              height: mediaSize.height,
              child: _youtubeProv.youtubePlayerList[index],
            );
          },
        );
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
