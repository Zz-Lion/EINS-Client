import 'package:eins_client/constants/color_constant.dart';
import 'package:eins_client/providers/youtube_provider.dart';
import 'package:eins_client/widgets/app_bar.dart';
import 'package:eins_client/widgets/bottom_navigation_bar.dart';
import 'package:eins_client/widgets/eins_youtube_player_widget.dart';
import 'package:eins_client/widgets/error_dialog.dart';
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
      } on Exception catch (e) {
        errorDialog(context, e);
      }
    }

    youtubePlayerList = List<Widget>.generate(
        _youtubeProv.length * 2 - 1,
        (index) => index % 2 == 0
            ? EinsYoutubePlayer(index: index ~/ 2)
            : Divider(
                thickness: 2,
                color: kPrimaryColor.withOpacity(0.4),
                indent: 15,
                endIndent: 15,
              ));
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

    final Widget defaultWidget = Builder(
        builder: (context) => Scaffold(
              appBar: appBar(),
              body: SafeArea(
                child: Builder(builder: (context) {
                  _scrollController =
                      ScrollController(initialScrollOffset: _scrollOffset);

                  return SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
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
              bottomNavigationBar: Container(
                  color: Colors.grey[300],
                  child: bottomNavigationBar(context, widget.controller, 1)),
            )).build(context);

    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        return defaultWidget;
      } else {
        _scrollOffset = _scrollController.offset;
        _scrollController.dispose();

        return IndexedStack(
          index: _youtubeProv.selectedIndex ?? 0,
          children: _youtubeProv.youtubePlayerList,
        );
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
