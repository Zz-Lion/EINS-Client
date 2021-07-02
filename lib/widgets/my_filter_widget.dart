import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constants.dart';
import 'package:eins_client/models/filter_model.dart';
import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

class MyFilter extends StatefulWidget {
  const MyFilter({Key? key}) : super(key: key);

  @override
  _MyFilterState createState() => _MyFilterState();
}

class _MyFilterState extends State<MyFilter> {
  late final LocalStorageProvider _localStorageProv;
  late List<Filter> _filters;
  late List<bool> _isEditable;
  late List<TextEditingController> _descTextController;
  late List<FocusNode> _focus;
  late List<Widget> _filterWidgets;
  late int _currentPage;

  @override
  void initState() {
    super.initState();

    _localStorageProv = context.read<LocalStorageProvider>();

    _filters = _localStorageProv.fetchData();
    _isEditable = List<bool>.generate(_filters.length, (index) => false);
    _descTextController = List<TextEditingController>.generate(_filters.length,
        (index) => TextEditingController(text: _filters[index].desc));
    _focus = List<FocusNode>.generate(_filters.length, (index) => FocusNode());
    _currentPage = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _filterWidgets =
        List<Widget>.from(_filters.map((e) => _makeFilterWidget(context, e)));
  }

  @override
  void dispose() {
    _descTextController.forEach((element) {
      element.dispose();
    });
    _focus.forEach((element) {
      element.dispose();
    });

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
    String? id = "4a81962323580";
    try {
      if (id != null) {
        DocumentSnapshot<Map<String, dynamic>> filterData =
            await filtersRef.doc(id).get();

        if (filterData.exists) {
          if (filterData.data()!["start_date"] == null) {
            final int value = await showModalBottomSheet(
              enableDrag: false,
              context: context,
              builder: (context) => Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "필터를 사용하시는 환경을 설정해주세요.",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _bottomSheetButton(context,
                          text: "3인 이하 가정집", icon: Icons.home_filled, num: 1),
                      _bottomSheetButton(context,
                          text: "4인 이상 가정집", icon: Icons.home_filled, num: 2),
                      _bottomSheetButton(context,
                          text: "사무실", icon: Icons.home_filled, num: 2),
                    ],
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
            );

            Map<String, dynamic> tempDoc = <String, dynamic>{};
            DateTime startDate = DateTime.now();
            DateTime replaceDate = startDate.add(Duration(
                days: 30 *
                    (filterData.data()!["default_duration"] as int) ~/
                    value));

            tempDoc.addAll(filterData.data()!);
            tempDoc.addAll({
              "id": id,
              "start_date": Timestamp.fromDate(startDate),
              "replace_date": Timestamp.fromDate(replaceDate),
              "desc": "나의 " + (filterData.data()!["product_name"] as String),
            });

            await filtersRef.doc(id).set(tempDoc);

            final DocumentSnapshot<Map<String, dynamic>> newFilterData;

            newFilterData = await filtersRef.doc(id).get();

            filterData = newFilterData;
          }

          WidgetsBinding.instance?.addPostFrameCallback((_) {
            setState(() {
              _filters.insert(0, Filter.fromDoc(filterData));

              _isEditable.insert(0, false);

              _filterWidgets.insert(0, _makeFilterWidget(context, _filters[0]));

              _descTextController.insert(
                  0, TextEditingController(text: _filters[0].desc));

              _focus.insert(0, FocusNode());

              _localStorageProv.saveData(_filters);
            });
          });
        } else {
          throw Exception("등록되지 않은 필터입니다.");
        }
      } else {
        throw Exception("NFC태그 id를 확인할 수 없습니다.");
      }
    } catch (e) {
      errorDialog(context, Exception(e));
    }
    // if (!(await NfcManager.instance.isAvailable())) {
    //   throw Exception("NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.");
    // }

    // try {
    //   if (Platform.isIOS) {
    //     await NfcManager.instance.startSession(
    //       alertMessage: "기기를 필터 가까이에 가져다주세요.",
    //       onDiscovered: (NfcTag tag) async {
    //         try {
    //           id = _handleTag(tag);
    //           await NfcManager.instance.stopSession(alertMessage: "완료되었습니다.");
    //         } catch (e) {
    //           id = null;

    //           throw Exception("NFC태그 정보를 불러올 수 없습니다.");
    //         }
    //       },
    //     );
    //   }

    //   if (Platform.isAndroid) {
    //     id = await showDialog(
    //       context: context,
    //       builder: (context) =>
    //           _AndroidSessionDialog("기기를 필터 가까이에 가져다주세요.", _handleTag),
    //     );
    //   }
    // } catch (e) {
    //   throw Exception("NFC태그 정보를 불러올 수 없습니다.");
    // }
  }

  Widget _makeFilterWidget(BuildContext context, Filter e) {
    final Size mediaSize = MediaQuery.of(context).size;
    final DateTime startDate = e.startDate;
    final DateTime replaceDate = e.replaceDate;
    final int allDay = replaceDate.difference(startDate).inDays;
    final int usageDay = DateTime.now().difference(startDate).inDays;
    final CachedNetworkImage? filterImage =
        context.read<ProductProvider>().productImageByName(e.productName);

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 54,
                    width: e.productName.length * 24,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Text(
                        e.productName,
                        style: Theme.of(context)
                            .textTheme
                            .headline1!
                            .copyWith(fontWeight: FontWeight.bold, height: 1),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: (mediaSize.height -
                          (Scaffold.of(context).appBarMaxHeight ?? 0.0) -
                          (68 + MediaQuery.of(context).padding.bottom) -
                          (mediaSize.width) +
                          10),
                      child: filterImage,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: mediaSize.width - 80,
                      height: (mediaSize.width - 80) * 3 / 4,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: Colors.deepPurple[300],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            final int filterIndex = _findIndex(e.id);

                            return Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 10,
                                  height: 30,
                                ),
                                Expanded(
                                  child: Container(
                                    height: 30,
                                    padding: const EdgeInsets.only(top: 5),
                                    child: _isEditable[filterIndex]
                                        ? TextField(
                                            focusNode: _focus[filterIndex],
                                            maxLength: 15,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.all(0),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white)),
                                              counterText: "",
                                            ),
                                            scrollPadding:
                                                const EdgeInsets.all(0),
                                            controller: _descTextController[
                                                filterIndex],
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(
                                                    color: Colors.grey[400]),
                                          )
                                        : Text(
                                            "${e.desc}",
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2,
                                          ),
                                  ),
                                ),
                                _isEditable[filterIndex]
                                    ? InkWell(
                                        child: Icon(
                                          Icons.check,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          _editFilter(context, filterIndex);
                                        },
                                      )
                                    : InkWell(
                                        child: Icon(
                                          Icons.edit,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _isEditable[filterIndex] = true;
                                            _focus[filterIndex].requestFocus();
                                          });
                                        },
                                      ),
                                const SizedBox(
                                  width: 10,
                                  height: 30,
                                ),
                                InkWell(
                                  child: Icon(
                                    Icons.delete,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    _deleteFilter(filterIndex);
                                  },
                                ),
                                const SizedBox(
                                  width: 10,
                                  height: 30,
                                ),
                              ],
                            );
                          }),
                          Stack(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    width:
                                        ((mediaSize.width - 80) * 3 / 4 - 30) /
                                            2,
                                    height: (mediaSize.width - 80) * 3 / 4 - 30,
                                    child: CustomPaint(
                                      painter: MyPainter(
                                        color: usageDay / allDay < 0.7
                                            ? Colors.blue[400]!
                                            : (usageDay / allDay < 0.9
                                                ? Colors.orange[400]!
                                                : Colors.red[700]!),
                                        radian: (usageDay / allDay) * pi,
                                      ),
                                      size: Size(
                                          ((mediaSize.width - 80) * 3 / 4 -
                                                  30) /
                                              2,
                                          (mediaSize.width - 80) * 3 / 4 - 30),
                                      child: Container(
                                        width: ((mediaSize.width - 80) * 3 / 4 -
                                                30) /
                                            2,
                                        height:
                                            (mediaSize.width - 80) * 3 / 4 - 30,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: mediaSize.width -
                                        80 -
                                        ((mediaSize.width - 80) * 3 / 4 - 30) /
                                            2,
                                    height: (mediaSize.width - 80) * 3 / 4 - 30,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text(
                                          "정수량",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                        Text(
                                          "${(usageDay / allDay * 100).toInt()}%",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        Text(
                                          "사용",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: (1 - cos((usageDay / allDay) * pi)) *
                                        ((mediaSize.width - 80) * 3 / 4 -
                                            30 -
                                            16) /
                                        2 +
                                    8 -
                                    12,
                                left: sin((usageDay / allDay) * pi) *
                                        ((mediaSize.width - 80) * 3 / 4 -
                                            30 -
                                            16) /
                                        2 -
                                    12,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: usageDay / allDay < 0.7
                                        ? Colors.blue[400]!
                                        : (usageDay / allDay < 0.9
                                            ? Colors.orange[400]!
                                            : Colors.red[700]!),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 4,
                                      color: usageDay / allDay < 0.7
                                          ? Colors.blue[100]!
                                          : (usageDay / allDay < 0.9
                                              ? Colors.orange[100]!
                                              : Colors.red[200]!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: mediaSize.width - 80,
                      height: (mediaSize.width - 80) / 4,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: Colors.deepPurple[300],
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "사용시작일",
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                Text(
                                  "${DateFormat("yyyy년 MM월 dd일").format(startDate)}",
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ),
                          VerticalDivider(
                            thickness: 2,
                            width: 2,
                            indent: 4,
                            endIndent: 4,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "필터교체일",
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                Text(
                                  "${DateFormat("yyyy년 MM월 dd일").format(replaceDate)}",
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: e.productName.length * 24,
            ),
            Container(
              height: mediaSize.height -
                  (Scaffold.of(context).appBarMaxHeight ?? 0.0) -
                  (68 + MediaQuery.of(context).padding.bottom) -
                  (mediaSize.width) +
                  30,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: filterImage,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _deleteFilter(int index) async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _filters.removeAt(index);
        _filterWidgets.removeAt(index);
        _isEditable.removeAt(index);
        _descTextController.removeAt(index);
        _focus.removeAt(index);

        _localStorageProv.saveData(_filters);
      });
    });
  }

  Future<void> _editFilter(BuildContext context, int index) async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _filters[index] =
            _filters[index].copyWith(desc: _descTextController[index].text);
        _filterWidgets[index] = _makeFilterWidget(context, _filters[index]);
        _isEditable[index] = false;
        _focus[index].unfocus();

        _localStorageProv.saveData(_filters);
      });
    });
  }

  int _findIndex(String id) {
    for (int i = 0; i < _filters.length; i++)
      if (_filters[i].id == id) return i;

    return 0;
  }

  Widget _bottomSheetButton(BuildContext context,
      {required String text, required IconData icon, required int num}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          height: MediaQuery.of(context).size.width * 0.25,
          decoration: BoxDecoration(
            color: Colors.indigo[200],
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: Colors.white,
              ),
              Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).pop(num);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        PageView(
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: <Widget>[
            ..._filterWidgets,
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _filterWidgets.length == 0
                      ? Text(
                          "등록된 필터가 없습니다. 필터를 등록해주세요!",
                          style: Theme.of(context).textTheme.bodyText1,
                        )
                      : Container(),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            color: Colors.deepPurple[300],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "새로운 필터 추가하기",
                                style: Theme.of(context).textTheme.subtitle2,
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
            )
          ],
        ),
        _filterWidgets.length == 0
            ? Container()
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        List<Widget>.generate(_filters.length * 2 + 1, (index) {
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
                        return SizedBox(width: 10);
                      }
                    }),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
      ],
    );
  }
}

class MyPainter extends CustomPainter {
  final Color color;
  final double radian;

  MyPainter({required this.color, required this.radian});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    canvas.drawArc(
        Rect.fromLTWH(
            0 - (size.width - 8), 8, size.width * 2 - 16, size.height - 16),
        0 - pi / 2,
        radian,
        false,
        paint);

    paint.color = Colors.white;

    canvas.drawArc(
        Rect.fromLTWH(
            0 - (size.width - 8), 8, size.width * 2 - 16, size.height - 16),
        radian - pi / 2,
        pi - radian,
        false,
        paint);
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
