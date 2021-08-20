import 'dart:async';

import 'package:async/async.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eins_client/constants/color_constant.dart';
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
            LocalStorageProvider localStorageProv, __) {
          MyFilterProvider myFilterProv = MyFilterProvider(
              productProv: productProv, localStorageProv: localStorageProv);

          myFilterProv.initFilter();

          return myFilterProv;
        },
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

class MyApp extends StatelessWidget {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future<void> _fetchData(BuildContext context) {
    return _memoizer.runOnce(() async {
      await _initializeEins(context);
    });
  }

  Future<bool?> _initNotiSetting() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    final InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    return await flutterLocalNotificationsPlugin.initialize(
      initSettings,
    );
  }

  Future<void> _initializeEins(BuildContext context) async {
    ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      throw "와이파이, 모바일 데이터 혹은 비행기모드 설정을 확인해 주시기 바랍니다.";
    }

    await Firebase.initializeApp();

    await context.read<ProductProvider>().getProductInfo();

    await context.read<YoutubeProvider>().getYoutubeInfo();

    await context.read<SalesProvider>().getSalesInfo();

    await context.read<LocalStorageProvider>().initLocalStorage();

    await context.read<QuestionProvider>().getQuestionInfo();

    context.read<MyFilterProvider>().initFilter();

    await _initNotiSetting();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchData(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: kBackgroundColor,
              appBarTheme: AppBarTheme(backgroundColor: kBackgroundColor),
            ),
            home: Builder(
              builder: (BuildContext context) {
                errorDialog(context, snapshot.error, afterDialog: (_) {
                  SystemChannels.platform.invokeMethod("SystemNavigator.pop");
                });
                return Splash();
              },
            ),
          );
        }

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
              scaffoldBackgroundColor: kBackgroundColor,
              appBarTheme: AppBarTheme(color: kBackgroundColor),
              primaryColor: kPrimaryColor,
              accentColor: kPrimaryColor,
              textSelectionTheme: TextSelectionThemeData(
                  cursorColor: kBackgroundColor,
                  selectionColor: kBackgroundColor,
                  selectionHandleColor: kBackgroundColor),
              textTheme:
                  Theme.of(context).textTheme.apply(bodyColor: kTextColor),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: EinsClientScreen(),
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case EinsClientScreen.routeName:
                  return MaterialPageRoute(builder: (_) => EinsClientScreen());
                case SalesWebViewScreen.routeName:
                  return PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        SalesWebViewScreen(url: settings.arguments as String),
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

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: kBackgroundColor,
            appBarTheme: AppBarTheme(backgroundColor: kBackgroundColor),
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
