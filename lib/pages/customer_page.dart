import 'dart:io';

import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/providers/my_filter_provider.dart';
import 'package:eins_client/screens/chatting_screen.dart';
import 'package:eins_client/screens/question_screen.dart';
import 'package:eins_client/widgets/app_bar.dart';
import 'package:eins_client/widgets/bottom_navigation_bar.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    Future<void> _makePhoneCall(String url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw "Could not launch $url";
      }
    }

    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: Builder(builder: (context) {
          return Container(
            width: mediaSize.width,
            height: mediaSize.height -
                (Scaffold.of(context).appBarMaxHeight ?? 0.0) -
                (68 + MediaQuery.of(context).padding.bottom),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.pushNamed(
                              context, QuestionScreen.routeName);
                        },
                        leading: Icon(
                          Icons.help_outline,
                          color: Colors.deepPurple[300],
                        ),
                        title: Text("자주 묻는 질문",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                      Divider(height: 10),
                      ListTile(
                        onTap: () {
                          try {
                            _makePhoneCall("tel:01055085350");
                          } catch (e) {
                            errorDialog(context, e as Exception);
                          }
                        },
                        leading: Icon(
                          Icons.call,
                          color: Colors.deepPurple[300],
                        ),
                        title: Text("담당자 전화 연결",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                      Divider(height: 10),
                      SwitchListTile(
                        secondary: Icon(
                          Icons.alarm,
                          color: Colors.deepPurple[300],
                        ),
                        title: Text("푸시 알람 ON/OFF",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        onChanged: (_) {
                          // context
                          //     .read<LocalStorageProvider>()
                          //     .toggleNotification();
                          context
                              .read<MyFilterProvider>()
                              .dailyAtTimeNotification();
                        },
                        value:
                            context.watch<LocalStorageProvider>().isNotificated,
                      ),
                      Divider(height: 10),
                      ListTile(
                        leading: Icon(
                          Icons.info_outlined,
                          color: Colors.deepPurple[300],
                        ),
                        title: Text("사업자 정보",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                      Divider(height: 10),
                      ListTile(
                        leading: Icon(
                          Platform.isIOS
                              ? Icons.phone_iphone
                              : Icons.phone_android,
                          color: Colors.deepPurple[300],
                        ),
                        title: Text("버전 정보",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        trailing: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 70),
                          child: FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (_, AsyncSnapshot<PackageInfo> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                  snapshot.data?.version ?? "",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ChattingScreen.routeName);
                  },
                  child: Container(
                    width: mediaSize.width,
                    height: 50,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.deepPurple,
                    ),
                    child: Center(
                      child: Text(
                        "1:1 문의하기",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: bottomNavigationBar(context, controller, 3),
    );
  }
}
