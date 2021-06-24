import 'package:eins_client/pages/customer_page.dart';
import 'package:eins_client/pages/home_page.dart';
import 'package:eins_client/pages/info_page.dart';
import 'package:eins_client/pages/product_page.dart';
import 'package:eins_client/providers/banner_provider.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:eins_client/providers/youtube_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<YoutubeProvider>(
        create: (_) => YoutubeProvider(),
      ),
      ChangeNotifierProvider<ProductProvider>(
        create: (_) => ProductProvider(),
      ),
      ChangeNotifierProvider<BannerProvider>(create: (_) => BannerProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  Future<void> _initializeEins(BuildContext context) async {
    await Firebase.initializeApp();

    await context.read<ProductProvider>().getProductInfo();

    await context.read<YoutubeProvider>().getYoutubeInfo();

    await context.read<BannerProvider>().getBannerInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeEins(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!);
            },
            title: "EINS",
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              appBarTheme: AppBarTheme(backgroundColor: Colors.white),
              tabBarTheme: TabBarTheme(
                labelColor: Colors.indigo,
                unselectedLabelColor: Colors.black,
              ),
            ),
            home: EinsClient(),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppBarTheme(backgroundColor: Colors.white),
          ),
          home: Splash(),
        );
      },
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeInImage(
          width: MediaQuery.of(context).size.width * 0.785,
          placeholder: MemoryImage(kTransparentImage),
          image: Image.asset(
            'assets/images/EINS_title.png',
            fit: BoxFit.fitWidth,
          ).image,
        ),
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
          InfoPage(controller: _pageController),
          ProductPage(controller: _pageController),
          CustomerPage(controller: _pageController),
        ],
      ),
    );
  }
}
