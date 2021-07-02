import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:eins_client/providers/sales_provider.dart';
import 'package:eins_client/providers/youtube_provider.dart';
import 'package:eins_client/screens/eins_client_screen.dart';
import 'package:eins_client/screens/sales_web_view_screen.dart';
import 'package:eins_client/widgets/error_dialog.dart';
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
      ChangeNotifierProvider<YoutubeProvider>(create: (_) => YoutubeProvider()),
      ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),
      ChangeNotifierProvider<SalesProvider>(create: (_) => SalesProvider()),
      ChangeNotifierProvider<LocalStorageProvider>(
          create: (_) => LocalStorageProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  Future<void> _initializeEins(BuildContext context) async {
    await Firebase.initializeApp();

    await context.read<ProductProvider>().getProductInfo();

    await context.read<YoutubeProvider>().getYoutubeInfo();

    await context.read<SalesProvider>().getSalesInfo();

    await context.read<LocalStorageProvider>().initLocalStorage();
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
                child: child!,
              );
            },
            title: "EINS",
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
              ),
              textTheme: TextTheme(
                headline1:
                    TextStyle(color: Colors.white, fontSize: 48, height: 1),
                subtitle1:
                    TextStyle(color: Colors.white, fontSize: 36, height: 1),
                subtitle2:
                    TextStyle(color: Colors.white, fontSize: 24, height: 1),
                bodyText1:
                    TextStyle(color: Colors.white, fontSize: 18, height: 1),
                bodyText2:
                    TextStyle(color: Colors.white, fontSize: 16, height: 1),
              ),
            ),
            home: EinsClient(),
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case EinsClient.routeName:
                  return MaterialPageRoute(builder: (_) => EinsClient());
                case SalesWebView.routeName:
                  return PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        SalesWebView(url: settings.arguments as String),
                    transitionsBuilder:
                        (_, Animation animation, __, Widget child) =>
                            SlideTransition(
                      position: animation.drive(Tween(
                        begin: Offset(0.0, 1.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.ease))),
                      child: child,
                    ),
                    transitionDuration: const Duration(milliseconds: 750),
                  );
              }
            },
          );
        }

        if (snapshot.hasError) {
          errorDialog(context, Exception(snapshot.error), afterDialog: (value) {
            SystemChannels.platform.invokeMethod("SystemNavigator.pop");
          });
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
