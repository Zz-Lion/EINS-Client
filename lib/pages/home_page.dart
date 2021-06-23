import 'package:eins_client/providers/banner_provider.dart';
import 'package:eins_client/widgets/eins_banner_widget.dart';
import 'package:eins_client/widgets/my_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
          child: Image.asset(
            'assets/images/EINS.jpg',
            height: 40,
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
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Text(
                "필터정보",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Text(
                "구매하기",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Text(
                "고객센터",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                EinsBanner(
                  einsBanners: context.read<BannerProvider>().bannerImages,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
