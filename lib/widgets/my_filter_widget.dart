import 'dart:io';
import 'package:eins_client/constants/color_constant.dart';
import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/providers/my_filter_provider.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:eins_client/widgets/filter_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';

class MyFilter extends StatefulWidget {
  const MyFilter({Key? key}) : super(key: key);

  @override
  _MyFilterState createState() => _MyFilterState();
}

class _MyFilterState extends State<MyFilter> {
  late PageController _controller;
  late int _currentPage;

  @override
  void initState() {
    super.initState();

    _controller = PageController();
    _currentPage = 0;
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  String _handleTag(NfcTag tag) {
    try {
      final List<int> tempIntList =
          List<int>.from(Ndef.from(tag)?.additionalData["identifier"]);
      String id = "";

      tempIntList.forEach((element) {
        id = id + element.toRadixString(16);
      });

      return id;
    } catch (e) {
      throw "NFC 데이터를 가져올 수 없습니다.";
    }
  }

  Future<void> _addFilter(BuildContext context) async {
    try {
      String? id;

      if (!(await NfcManager.instance.isAvailable())) {
        if (Platform.isAndroid) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("오류"),
              content: Text(
                "NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    AppSettings.openNFCSettings();
                  },
                  child: Text("설정", style: TextStyle(color: kPrimaryColor)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("확인", style: TextStyle(color: kPrimaryColor)),
                ),
              ],
            ),
          );

          return;
        }

        throw "NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.";
      }

      try {
        if (Platform.isIOS) {
          await NfcManager.instance.startSession(
            alertMessage: "기기를 필터 가까이에 가져다주세요.",
            onDiscovered: (NfcTag tag) async {
              try {
                id = _handleTag(tag);
                await NfcManager.instance.stopSession(alertMessage: "완료되었습니다.");
              } catch (e) {
                id = null;

                throw "NFC태그 정보를 불러올 수 없습니다.";
              }
            },
          );
        }

        if (Platform.isAndroid) {
          id = await showDialog(
            context: context,
            builder: (context) =>
                _AndroidSessionDialog("기기를 필터 가까이에 가져다주세요.", _handleTag),
          );
        }
      } catch (e) {
        throw "NFC태그 정보를 불러올 수 없습니다.";
      }

      if (id != null) {
        if (context.read<MyFilterProvider>().findIndex(id!) != null) {
          throw "이미 등록된 필터 입니다";
        }

        _currentPage = 0;
        _controller.jumpToPage(0);
        context.read<MyFilterProvider>().addFilter(context, id!);
      } else {
        throw "NFC태그 id를 확인할 수 없습니다.";
      }
    } catch (e) {
      errorDialog(context, e);
    }

    if (context.read<LocalStorageProvider>().isNotificated) {
      context.read<MyFilterProvider>().dailyAtTimeNotification();
    }
  }

  Widget _registerFilter(BuildContext context, int length) {
    final Size mediaSize = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[
        Expanded(
          child: Visibility(
            visible: length == 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "assets/images/1.svg",
                  height: 36,
                ),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  "assets/images/2.svg",
                  height: 40,
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 10),
          width: mediaSize.width,
          height: mediaSize.width * 4 / 5,
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "새로운 필터 추가하기",
                style: TextStyle(color: Colors.white, fontSize: 24, height: 1),
              ),
              Spacer(),
              IconButton(
                iconSize: 54,
                color: Colors.white,
                icon: Icon(Icons.add_circle),
                onPressed: () {
                  _addFilter(context);
                },
              ),
              Spacer(),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: 5,
                height: 5,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.7)),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final int length = context
        .select<MyFilterProvider, int>((myFilterProv) => myFilterProv.length);

    return Stack(
      children: <Widget>[
        PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: <Widget>[
            ...List<FilterItem>.generate(
                length, (index) => FilterItem(key: UniqueKey(), index: index)),
            _registerFilter(context, length),
          ],
        ),
        Positioned(
          bottom: mediaSize.width * 4 / 5 - 15,
          child: Container(
            width: mediaSize.width,
            child: Visibility(
              visible: !(length == 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(length * 2 + 1, (index) {
                  if (index % 2 == 0) {
                    return AnimatedContainer(
                      duration: Duration(microseconds: 800),
                      width: index / 2 == _currentPage ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: index / 2 == _currentPage
                            ? kBackgroundColor
                            : kBackgroundColor.withOpacity(0.4),
                      ),
                    );
                  } else {
                    return const SizedBox(width: 6);
                  }
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AndroidSessionDialog extends StatefulWidget {
  const _AndroidSessionDialog(this.alertMessage, this.handleTag);

  final String alertMessage;

  final String Function(NfcTag tag) handleTag;

  @override
  State<StatefulWidget> createState() => _AndroidSessionDialogState();
}

class _AndroidSessionDialogState extends State<_AndroidSessionDialog> {
  String? _alertMessage;
  String? _errorMessage;

  String? _result;

  @override
  void initState() {
    super.initState();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          _result = widget.handleTag(tag);

          await NfcManager.instance.stopSession();

          setState(() => _alertMessage = "NFC 태그를 인식하였습니다.");
        } catch (e) {
          await NfcManager.instance.stopSession();

          setState(() => _errorMessage = '$e');
        }
      },
    ).catchError((e) => setState(() => _errorMessage = '$e'));
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _errorMessage?.isNotEmpty == true
            ? "오류"
            : _alertMessage?.isNotEmpty == true
                ? "성공"
                : "준비",
      ),
      content: Text(
        _errorMessage?.isNotEmpty == true
            ? _errorMessage!
            : _alertMessage?.isNotEmpty == true
                ? _alertMessage!
                : widget.alertMessage,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
              _errorMessage?.isNotEmpty == true
                  ? "확인"
                  : _alertMessage?.isNotEmpty == true
                      ? "완료"
                      : "취소",
              style: TextStyle(color: kPrimaryColor)),
          onPressed: () => Navigator.of(context).pop(_result),
        ),
      ],
    );
  }
}
