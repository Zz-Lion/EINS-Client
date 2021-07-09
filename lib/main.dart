import 'package:async/async.dart';
import 'package:eins_client/providers/chatting_provider.dart';
import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/providers/my_filter_provider.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:eins_client/providers/question_provider.dart';
import 'package:eins_client/providers/sales_provider.dart';
import 'package:eins_client/providers/youtube_provider.dart';
import 'package:eins_client/screens/chatting_screen.dart';
import 'package:eins_client/screens/eins_client_screen.dart';
import 'package:eins_client/screens/question_screen.dart';
import 'package:eins_client/screens/sales_web_view_screen.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<YoutubeProvider>(create: (_) => YoutubeProvider()),
      Provider<ProductProvider>(create: (_) => ProductProvider()),
      Provider<SalesProvider>(create: (_) => SalesProvider()),
      ChangeNotifierProvider<LocalStorageProvider>(
          create: (_) => LocalStorageProvider()),
      ChangeNotifierProxyProvider2<ProductProvider, LocalStorageProvider,
          MyFilterProvider>(
        create: (_) => MyFilterProvider(
            productProv: ProductProvider(),
            localStorageProv: LocalStorageProvider()),
        update: (_, ProductProvider productProv,
                LocalStorageProvider localStorageProv, __) =>
            MyFilterProvider(
                productProv: productProv, localStorageProv: localStorageProv),
      ),
      ChangeNotifierProxyProvider<LocalStorageProvider, ChattingProvider>(
        create: (_) => ChattingProvider(""),
        update: (_, LocalStorageProvider localStorageProv, __) =>
            ChattingProvider(localStorageProv.uid),
      ),
      Provider<QuestionProvider>(create: (_) => QuestionProvider()),
    ],
    child: MyApp(),
  ));
}

Future<bool?> _initNotiSetting() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final IOSInitializationSettings initSettingsIOS = IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );
  final InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );

  return await flutterLocalNotificationsPlugin.initialize(
    initSettings,
  );
}

class MyApp extends StatelessWidget {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future<void> _fetchData(BuildContext context) {
    return _memoizer.runOnce(() async {
      await _initializeEins(context);
    });
  }

  Future<void> _initializeEins(BuildContext context) async {
    await Firebase.initializeApp();

    await context.read<ProductProvider>().getProductInfo();

    await context.read<YoutubeProvider>().getYoutubeInfo();

    await context.read<SalesProvider>().getSalesInfo();

    await context.read<LocalStorageProvider>().initLocalStorage();

    await context.read<QuestionProvider>().getQuestionInfo();

    bool? result = await _initNotiSetting();

    if (result == true &&
        context.read<LocalStorageProvider>().isNotificated == false) {
      context.read<LocalStorageProvider>().toggleNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchData(context),
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
                case ChattingScreen.routeName:
                  return MaterialPageRoute(builder: (_) => ChattingScreen());
                case QuestionScreen.routeName:
                  return MaterialPageRoute(builder: (_) => QuestionScreen());
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
