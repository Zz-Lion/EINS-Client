import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/color_constant.dart';
import 'package:eins_client/models/chatting_model.dart';
import 'package:eins_client/providers/chatting_provider.dart';
import 'package:eins_client/providers/my_filter_provider.dart';
import 'package:eins_client/widgets/chatting_item_widget.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChattingScreen extends StatefulWidget {
  static const String routeName = '/customer';

  const ChattingScreen({Key? key}) : super(key: key);

  @override
  _ChattingScreenState createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  late TextEditingController _controller;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _streamSubscription;
  bool firstLoad = true;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();

    final ChattingProvider chattingProv = context.read<ChattingProvider>();

    _controller = TextEditingController();
    _streamSubscription = chattingProv.getSnapshot().listen((event) {
      if (firstLoad) {
        firstLoad = false;
        return;
      }

      chattingProv.addChatting(ChattingModel.fromDoc(event.docs[0]));
    }, onError: (e) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        errorDialog(
          context,
          Exception("정보를 불러올 수 없습니다."),
          afterDialog: (value) {
            Navigator.pop(context);
          },
        );
      });
    });
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      chattingProv.loadChatting();
    });
    _focus = FocusNode();

    chattingProv.updateCustomerInfo(context.read<MyFilterProvider>().filters);
  }

  @override
  void dispose() {
    _controller.dispose();
    _streamSubscription.cancel();
    _focus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChattingProvider chattingProv = context.watch<ChattingProvider>();
    final ChattingProgressState chattingState =
        context.watch<ChattingProvider>().state;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black)),
        title: Text("EINS 고객센터", style: TextStyle(color: Colors.black)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _focus.unfocus();
                },
                child: Container(
                  color: kPrimaryColor.withOpacity(0.2),
                  child: ListView(
                    reverse: true,
                    children: chattingProv.chattingList
                        .map<ChattingItem>(
                            (e) => ChattingItem(chattingModel: e))
                        .toList(),
                  ),
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                      child: TextField(
                        focusNode: _focus,
                        controller: _controller,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: chattingState.loading
                        ? null
                        : () {
                            chattingProv.sendChatting(_controller.text);

                            _controller.text = "";
                          },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                      child: Icon(
                        Icons.send,
                        size: 33,
                        color: kPrimaryColor,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
