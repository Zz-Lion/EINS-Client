import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constants.dart';
import 'package:eins_client/widgets/eins_banner_widget.dart';
import 'package:eins_client/widgets/my_filter_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  static final AsyncMemoizer<DocumentSnapshot<Map<String, dynamic>>> _memoizer =
      AsyncMemoizer<DocumentSnapshot<Map<String, dynamic>>>();

  _fetchData(Future<DocumentSnapshot<Map<String, dynamic>>> future) {
    return _memoizer.runOnce(() {
      return future;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final Future<DocumentSnapshot<Map<String, dynamic>>> einsBanners =
        adRef.doc("banners").get();

    return Scaffold(
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
            controller.jumpToPage(index);
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
        return SingleChildScrollView(
          child: Container(
            height: mediaSize.height -
                (Scaffold.of(context).appBarMaxHeight ?? 0.0),
            width: mediaSize.width,
            color: Colors.indigo[100],
            child: Column(
              children: <Widget>[
                Expanded(
                    child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: MyFilter(),
                )),
                const SizedBox(height: 10),
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: _fetchData(einsBanners),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final List<String> urlData = List<String>.from(
                          snapshot.data!.data()!["image_url"]);

                      return EinsBanner(
                        einsBanners: List<Image>.generate(
                            urlData.length,
                            (index) => Image.network(
                                  urlData[index],
                                  fit: BoxFit.fill,
                                )),
                      );
                    }

                    return Container(
                      width: mediaSize.width,
                      height: mediaSize.width * 0.4,
                      child: const Center(child: LinearProgressIndicator()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
