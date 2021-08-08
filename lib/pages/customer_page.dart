import 'dart:io';

import 'package:eins_client/constants/color_constant.dart';
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

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key, required this.controller}) : super(key: key);

  final PageController controller;

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  bool _isOpen = false;

  Future<void> _makePhoneCall(BuildContext context, String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw "전화할 수 없습니다.";
      }
    } catch (e) {
      errorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

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
                          color: kPrimaryColor,
                        ),
                        title: Text("자주 묻는 질문",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                      Divider(height: 10),
                      ListTile(
                        onTap: () {
                          _makePhoneCall(context, "tel:01055085350");
                        },
                        leading: Icon(
                          Icons.call,
                          color: kPrimaryColor,
                        ),
                        title: Text("담당자 전화 연결",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                      Divider(height: 10),
                      SwitchListTile(
                        activeColor: kPrimaryColor,
                        secondary: Icon(
                          Icons.alarm,
                          color: kPrimaryColor,
                        ),
                        title: Text("푸시 알람 ON/OFF",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        onChanged: (_) {
                          if (context
                              .read<LocalStorageProvider>()
                              .isNotificated) {
                            context
                                .read<MyFilterProvider>()
                                .deleteNotification();
                          } else {
                            context
                                .read<MyFilterProvider>()
                                .dailyAtTimeNotification();
                          }

                          context
                              .read<LocalStorageProvider>()
                              .toggleNotification();
                        },
                        value:
                            context.watch<LocalStorageProvider>().isNotificated,
                      ),
                      Divider(height: 10),
                      ListTile(
                        onTap: () {
                          setState(() {
                            _isOpen = !_isOpen;
                          });
                        },
                        leading: Icon(
                          Icons.info_outlined,
                          color: kPrimaryColor,
                        ),
                        title: Text("사업자 정보",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        trailing: Icon(_isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                      ),
                      Visibility(
                        visible: _isOpen,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "아인스코리아(주)",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: kTextColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text("사업자등록번호 761-81-01229",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kTextColor,
                                  )),
                              Text("통신판매업신고번호 2018-용인수지-0551호",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kTextColor,
                                  )),
                              Text("대표이사 김영수 경기도 용인시 수지구 풍덕천로 30번길 19",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kTextColor,
                                  )),
                              Text("전화 1670-3692 이메일 eins3692@naver.com",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kTextColor,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Divider(height: 10),
                      ListTile(
                        leading: Icon(
                          Platform.isIOS
                              ? Icons.phone_iphone
                              : Icons.phone_android,
                          color: kPrimaryColor,
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
                              return CircularProgressIndicator();
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
                      color: kPrimaryColor,
                    ),
                    child: Center(
                      child: Text(
                        "1:1 문의하기",
                        style: TextStyle(
                          color: kBackgroundColor,
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
      bottomNavigationBar: bottomNavigationBar(context, widget.controller, 3),
    );
  }
}
