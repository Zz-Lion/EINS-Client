import 'dart:io';
import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/providers/my_filter_provider.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:eins_client/widgets/filter_item_widget.dart';
import 'package:flutter/material.dart';
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

    context.read<MyFilterProvider>().initFilter();
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
      throw Exception("NFC 데이터를 가져올 수 없습니다.");
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
                  child: Text("설정"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("확인"),
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

        context.read<MyFilterProvider>().addFilter(context, id!);
      } else {
        throw "NFC태그 id를 확인할 수 없습니다.";
      }
    } catch (e) {
      errorDialog(context, Exception(e));
    }

    if (context.read<LocalStorageProvider>().isNotificated) {
      context.read<MyFilterProvider>().dailyAtTimeNotification();
    }
  }

  Widget _registerFilter(BuildContext context, int length) {
    final Size mediaSize = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Visibility(
            visible: length == 0,
            child: Text(
              "등록된 필터가 없습니다. 필터를 등록해주세요!",
              style: TextStyle(color: Colors.white, fontSize: 18, height: 1),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 10),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: mediaSize.width - 80,
                  height: mediaSize.width - 80,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    color: Colors.deepPurple[300],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "새로운 필터 추가하기",
                        style: TextStyle(
                            color: Colors.white, fontSize: 24, height: 1),
                      ),
                      IconButton(
                        iconSize: 60,
                        color: Colors.white,
                        icon: Icon(Icons.add_circle_outline_outlined),
                        onPressed: () {
                          _addFilter(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                length, (index) => FilterItem(index: index)),
            _registerFilter(context, length),
          ],
        ),
        Visibility(
          visible: !(length == 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(length * 2 + 1, (index) {
                  if (index % 2 == 0) {
                    return Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.deepPurple[900]!,
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                        color: index / 2 == _currentPage
                            ? Colors.deepPurple
                            : Colors.deepPurple[100],
                      ),
                    );
                  } else {
                    return const SizedBox(width: 10);
                  }
                }),
              ),
              const SizedBox(height: 5),
            ],
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

  @override
  void initState() {
    super.initState();

    NfcManager.instance.startSession(
      onDiscovered: (tag) async {
        try {
          final result = widget.handleTag(tag);
          await NfcManager.instance.stopSession();
          setState(() => _alertMessage = result);
        } catch (e) {
          await NfcManager.instance.stopSession().catchError((_) {/* no op */});
          setState(() => _errorMessage = '$e');
        }
      },
    ).catchError((e) => setState(() => _errorMessage = '$e'));
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession().catchError((_) {/* no op */});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _errorMessage?.isNotEmpty == true
            ? 'Error'
            : _alertMessage?.isNotEmpty == true
                ? 'Success'
                : 'Ready to scan',
      ),
      content: Text(
        _errorMessage?.isNotEmpty == true
            ? _errorMessage!
            : _alertMessage?.isNotEmpty == true
                ? _alertMessage!
                : widget.alertMessage,
      ),
      actions: [
        TextButton(
          child: Text(
            _errorMessage?.isNotEmpty == true
                ? 'GOT IT'
                : _alertMessage?.isNotEmpty == true
                    ? 'OK'
                    : 'CANCEL',
          ),
          onPressed: () => Navigator.pop(context, _alertMessage),
        ),
      ],
    );
  }
}
