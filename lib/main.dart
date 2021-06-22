import 'package:async/async.dart';
import 'package:eins_client/pages/customerpage.dart';
import 'package:eins_client/pages/homepage.dart';
import 'package:eins_client/pages/infopage.dart';
import 'package:eins_client/pages/productpage.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:eins_client/providers/youtube_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<YoutubeProvider>(
          create: (_) => YoutubeProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!);
        },
        title: "EINS",
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: Builder(builder: (context) {
          return FutureBuilder<void>(
              future: Provider.of<ProductProvider>(context, listen: false)
                  .getProductInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return EinsClient();
                }
                return Container();
              });
        }),
      ),
    );
  }
}

class EinsClient extends StatefulWidget {
  const EinsClient({
    Key? key,
  }) : super(key: key);

  @override
  _EinsClientState createState() => _EinsClientState();
}

class _EinsClientState extends State<EinsClient> {
  late PageController _pageController;
  final AsyncMemoizer<void> _memoizer = AsyncMemoizer<void>();

  _fetchData(Future<void> future) {
    return _memoizer.runOnce(() => future);
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomePage(controller: _pageController),
          FutureBuilder<void>(
            future:
                _fetchData(context.read<YoutubeProvider>().getYoutubeInfo()),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return InfoPage(controller: _pageController);
              }

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
                  bottom: const TabBar(
                    onTap: null,
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
                body: Container(
                    color: Colors.indigo[100],
                    child: Center(child: CircularProgressIndicator())),
              );
            },
          ),
          ProductPage(controller: _pageController),
          CustomerPage(controller: _pageController),
        ],
      ),
    );
  }
}
