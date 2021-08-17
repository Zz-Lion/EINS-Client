import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eins_client/constants/color_constant.dart';
import 'package:eins_client/models/filter_model.dart';
import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/providers/my_filter_provider.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:eins_client/widgets/custom_dotted_line.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

class FilterItem extends StatefulWidget {
  const FilterItem({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  _FilterItemState createState() => _FilterItemState();
}

class _FilterItemState extends State<FilterItem> {
  late final FilterModel e;
  late final DateTime startDate;
  late final DateTime replaceDate;
  late final int allDay;
  late final int usageDay;
  late final CachedNetworkImage? filterImage;

  late bool _isEditable;
  late TextEditingController _descTextController;
  late FocusNode _focus;
  Timer? _timer;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    e = context.read<MyFilterProvider>().filters[widget.index];
    startDate = e.startDate;
    replaceDate = e.replaceDate;
    allDay = replaceDate.difference(startDate).inDays;
    if (DateTime.now().isBefore(replaceDate)) {
      usageDay = DateTime.now().difference(startDate).inDays;
    } else {
      usageDay = allDay;
      _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          setState(() {
            _opacity = _opacity == 0.0 ? 1.0 : 0.0;
          });
        });
      });
    }

    filterImage =
        context.read<ProductProvider>().productImageByName(e.productName);

    _isEditable = false;
    _descTextController = TextEditingController(text: e.desc);
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _descTextController.dispose();
    _focus.dispose();
    _timer?.cancel();

    super.dispose();
  }

  Future<void> _deleteFilter(BuildContext context) async {
    final MyFilterProvider myFilterProv = context.read<MyFilterProvider>();
    final bool result;
    try {
      if (Platform.isIOS) {
        result = await showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("필터를 삭제하시겠습니까?"),
              content: Text("필터 정보를 삭제하시면 다시 필터를 등록해야만 복구됩니다."),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("취소"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text("삭제"),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );
      } else {
        result = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("필터를 삭제하시겠습니까?"),
              content: Text(
                "필터 정보를 삭제하시면 다시 필터를 등록해야만 복구됩니다.",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("삭제", style: TextStyle(color: kPrimaryColor)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("취소", style: TextStyle(color: kPrimaryColor)),
                ),
              ],
            );
          },
        );
      }

      if (result == true) {
        await myFilterProv.deleteFilter(widget.index);
      }
    } catch (e) {
      errorDialog(context, e);
    }
    if (context.read<LocalStorageProvider>().isNotificated) {
      context.read<MyFilterProvider>().dailyAtTimeNotification();
    }
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

  Future<void> _replaceFilter(BuildContext context) async {
    final MyFilterProvider myFilterProv = context.read<MyFilterProvider>();

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
          NfcManager.instance.startSession(
            pollingOptions: {
              NfcPollingOption.iso14443,
              NfcPollingOption.iso15693,
              NfcPollingOption.iso18092,
            },
            alertMessage: "기기를 필터 가까이에 가져다주세요.",
            onDiscovered: (NfcTag tag) async {
              print('test');
              try {
                id = _handleTag(tag);

                await NfcManager.instance.stopSession(alertMessage: "완료되었습니다.");
              } catch (e) {
                await NfcManager.instance.stopSession(alertMessage: "완료되었습니다.");

                id = null;
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

        final String tempDesc = myFilterProv.filters[widget.index].desc;

        await context
            .read<MyFilterProvider>()
            .addFilter(context, id!, widget.index);

        await myFilterProv.deleteFilter(widget.index + 1);

        await myFilterProv.editFilter(widget.index, tempDesc);
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

  Future<void> _editFilter(BuildContext context, String originalText) async {
    final MyFilterProvider myFilterProv = context.read<MyFilterProvider>();

    try {
      await myFilterProv.editFilter(widget.index, _descTextController.text);

      if (context.read<LocalStorageProvider>().isNotificated) {
        context.read<MyFilterProvider>().dailyAtTimeNotification();
      }
    } catch (e) {
      _descTextController.text = originalText;

      errorDialog(context, "필터 이름을 다시 설정해주세요.");
    } finally {
      setState(() {
        _isEditable = false;
        _focus.unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final String originalText = _descTextController.text;

    return Stack(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 20),
            Opacity(
              opacity: 0.5,
              child: Container(
                height: (mediaSize.height -
                        (Scaffold.of(context).appBarMaxHeight ?? 0.0) -
                        (68 + MediaQuery.of(context).padding.bottom)) *
                    0.7,
                child: filterImage,
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                    child: SizedBox.expand(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width:
                                    (mediaSize.width - 60) * usageDay / allDay,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                ),
                              ),
                              Container(
                                width: (mediaSize.width - 60) *
                                    (allDay - usageDay) /
                                    allDay,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[350],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 27),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${DateFormat("yyyy.MM.dd").format(startDate)}",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              ),
                              Text(
                                "${DateFormat("yyyy.MM.dd").format(replaceDate)}",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    left: (mediaSize.width - 60) * usageDay / allDay + 10,
                    child: Column(
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/icons/checkbox.svg",
                          width: 12,
                          height: 12,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kBackgroundColor,
                            border: Border.all(color: kPrimaryColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              "${(usageDay / allDay * 100).toInt()}%",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: mediaSize.width,
              height: mediaSize.width * 4 / 5,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 10,
                        height: 30,
                      ),
                      Expanded(
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.only(top: 5),
                          child: _isEditable
                              ? TextField(
                                  focusNode: _focus,
                                  maxLength: 15,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(0),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: kBackgroundColor)),
                                    counterText: "",
                                  ),
                                  scrollPadding: const EdgeInsets.all(0),
                                  controller: _descTextController,
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 24,
                                      height: 1),
                                )
                              : Text(
                                  "${_descTextController.text}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: kBackgroundColor,
                                      fontSize: 24,
                                      height: 1),
                                ),
                        ),
                      ),
                      _isEditable
                          ? GestureDetector(
                              child: Icon(
                                Icons.check,
                                size: 24,
                                color: kBackgroundColor,
                              ),
                              onTap: () {
                                if (originalText != _descTextController.text) {
                                  _editFilter(context, originalText);
                                } else {
                                  setState(() {
                                    _isEditable = false;
                                    _focus.unfocus();
                                  });
                                }
                              },
                            )
                          : GestureDetector(
                              child: Icon(
                                Icons.edit,
                                size: 24,
                                color: kBackgroundColor,
                              ),
                              onTap: () {
                                setState(() {
                                  _isEditable = true;
                                  _focus.requestFocus();
                                });
                              },
                            ),
                      const SizedBox(
                        width: 10,
                        height: 30,
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.delete,
                          size: 24,
                          color: kBackgroundColor,
                        ),
                        onTap: () {
                          _deleteFilter(context);
                        },
                      ),
                      const SizedBox(
                        width: 10,
                        height: 30,
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      PhysicalModel(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        elevation: 10,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: kBackgroundColor),
                          child: Center(
                            child: CustomPaint(
                              painter: MyPainter(
                                radian: (usageDay / allDay) * pi * 2,
                              ),
                              child: PhysicalModel(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                elevation: 2,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kBackgroundColor),
                                  child: Center(
                                    child: Text(
                                      "${(usageDay / allDay * 100).toInt()}%",
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: customDottedLine(CustomAxis.row),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 120,
                        height: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              height: 2,
                              child: customDottedLine(CustomAxis.row),
                            ),
                            Expanded(
                              child: customDottedLine(CustomAxis.column),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "정수량",
                                  style: TextStyle(
                                      color: kBackgroundColor,
                                      fontSize: 20,
                                      height: 1.0),
                                ),
                                Container(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        "${(usageDay / allDay * 100).toInt()}%  ",
                                        style: TextStyle(
                                            color: kBackgroundColor,
                                            fontSize: 24,
                                            height: 1.2),
                                      ),
                                      Text(
                                        "사용",
                                        style: TextStyle(
                                            color: kBackgroundColor,
                                            fontSize: 16,
                                            height: 1.2),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 120,
                                  child: usageDay == allDay
                                      ? Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.change_circle,
                                              size: 36,
                                              color: kBackgroundColor,
                                            ),
                                            onTap: () {
                                              _replaceFilter(context);
                                            },
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              "마지막 교체",
                                              style: TextStyle(
                                                  color: kBackgroundColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.6),
                                            ),
                                            Text(
                                              "${usageDay ~/ 30}개월 전",
                                              style: TextStyle(
                                                  color: kBackgroundColor,
                                                  fontSize: 12,
                                                  height: 1.6),
                                            )
                                          ],
                                        ),
                                ),
                                Container(
                                  width: 120,
                                  child: usageDay == allDay
                                      ? Align(
                                          alignment: Alignment.centerRight,
                                          child: AnimatedOpacity(
                                            duration: const Duration(
                                                milliseconds: 700),
                                            opacity: _opacity,
                                            child: Text(
                                              "필터 교체 버튼",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: kBackgroundColor,
                                                  fontSize: 12,
                                                  height: 1.2),
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              "다음 교체",
                                              style: TextStyle(
                                                  color: kBackgroundColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.6),
                                            ),
                                            Text(
                                              "${(allDay - usageDay) ~/ 30}개월 후",
                                              style: TextStyle(
                                                  color: kBackgroundColor,
                                                  fontSize: 12,
                                                  height: 1.6),
                                            )
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MyPainter extends CustomPainter {
  final double radian;

  MyPainter({required this.radian});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = kPrimaryColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    canvas.drawArc(
        Rect.fromLTWH(-15, -15, 90, 90), 0 - pi / 2, radian, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
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
