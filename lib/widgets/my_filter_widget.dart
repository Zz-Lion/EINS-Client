import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eins_client/constants/db_constants.dart';
import 'package:eins_client/models/filter_model.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

class MyFilter extends StatefulWidget {
  const MyFilter({Key? key}) : super(key: key);

  @override
  _MyFilterState createState() => _MyFilterState();
}

class _MyFilterState extends State<MyFilter>
    with AutomaticKeepAliveClientMixin<MyFilter> {
  late final LocalStorage storage;
  late List<Filter> _filters;
  late List<Widget> _filterWidgets;
  late List<bool> _isEditable;
  late bool _initialized;
  late List<TextEditingController> _descTextController;
  late List<FocusNode> _focus;

  @override
  void initState() {
    super.initState();

    storage = LocalStorage('eins_filter');
    _filters = <Filter>[];
    _filterWidgets = <Widget>[];
    _isEditable = <bool>[];
    _initialized = false;
    _descTextController = <TextEditingController>[];
    _focus = <FocusNode>[];
  }

  @override
  void dispose() {
    storage.dispose();
    _descTextController.forEach((element) {
      element.dispose();
    });
    _focus.forEach((element) {
      element.dispose();
    });

    super.dispose();
  }

  _saveToStorage() {
    storage.setItem('eins_filter', (_filters.map((e) => e.toJson())).toList());
  }

  Future<String> handleTag(NfcTag tag) async {
    final List<int> tempIntList =
        List<int>.from(Ndef.from(tag)?.additionalData["identifier"]);
    String id = "";

    tempIntList.forEach((element) {
      id = id + element.toRadixString(16);
    });

    final DocumentSnapshot<Map<String, dynamic>> filterData =
        await filtersRef.doc(id).get();

    return filterData.data()!["product_name"] as String;
  }

  _addFilter(BuildContext context) async {
    String? result;

    if (!(await NfcManager.instance.isAvailable())) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('오류'),
          content: Text('NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    if (Platform.isIOS) {
      return NfcManager.instance.startSession(
        alertMessage: "기기를 필터 가까이에 가져다주세요.",
        onDiscovered: (NfcTag tag) async {
          try {
            result = await handleTag(tag);
            if (result == null) return;
            await NfcManager.instance.stopSession(alertMessage: result);
          } catch (e) {
            await NfcManager.instance.stopSession(errorMessage: '$e');
          }
        },
      );
    }

    if (Platform.isAndroid) {
      result = await showDialog(
        context: context,
        builder: (context) =>
            _AndroidSessionDialog("기기를 필터 가까이에 가져다주세요.", handleTag),
      );
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _filters.insert(
            0,
            Filter(
              id: DateTime.now().toString(),
              productName: result!,
              defaultDuration: 12,
              startDate: DateTime(2021, 1, 1),
              replaceDate: DateTime(2021, 12, 31),
              desc: "테스트입니다.",
            ));

        _isEditable.insert(0, false);

        _filterWidgets.insert(0, _makeFilterWidget(context, _filters[0]));

        _descTextController.insert(
            0, TextEditingController(text: _filters[0].desc));

        _focus.insert(0, FocusNode());

        _saveToStorage();
      });
    });
  }

  Widget _makeFilterWidget(BuildContext context, Filter e) {
    final Size mediaSize = MediaQuery.of(context).size;
    final DateTime startDate = e.startDate;
    final DateTime replaceDate = e.replaceDate;
    final int allDay = replaceDate.difference(startDate).inDays;
    final int usageDay = DateTime.now().difference(startDate).inDays;
    final CachedNetworkImage? filterImage =
        context.read<ProductProvider>().productImageByName(e.productName);

    return Container(
      width: mediaSize.width - 20,
      height: (mediaSize.width - 20) * 3 / 4,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 10,
          color: Colors.indigo[300]!,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            final int filterIndex = _findIndex(e.id);

            return Row(
              children: <Widget>[
                const SizedBox(
                  width: 10,
                  height: 30,
                ),
                Container(
                    height: 30,
                    width: mediaSize.width - 118,
                    padding: const EdgeInsets.only(top: 5),
                    child: _isEditable[filterIndex]
                        ? TextField(
                            focusNode: _focus[filterIndex],
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(0),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo)),
                            ),
                            scrollPadding: const EdgeInsets.all(0),
                            controller: _descTextController[filterIndex],
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                height: 1.0,
                                fontWeight: FontWeight.bold),
                          )
                        : Text(
                            "${e.desc}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20,
                                height: 1.0,
                                fontWeight: FontWeight.bold),
                          )),
                _isEditable[filterIndex]
                    ? InkWell(
                        child: Icon(
                          Icons.check,
                          size: 24,
                          color: Colors.indigo[900],
                        ),
                        onTap: () {
                          _editFilter(context, filterIndex);
                        },
                      )
                    : InkWell(
                        child: Icon(
                          Icons.edit,
                          size: 24,
                          color: Colors.indigo[900],
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
                    color: Colors.indigo[900],
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
          Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    border: Border(
                  top: BorderSide(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                  right: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                )),
                width: (mediaSize.width - 40) / 2,
                height: (mediaSize.width - 20) / 2 - 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "사용 시작일",
                      style: TextStyle(
                        color: Colors.indigo[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text("${DateFormat("yyyy년 MM월 dd일").format(startDate)}"),
                    Text("${DateFormat("a hh:mm").format(startDate)}"),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border(
                  top: BorderSide(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                  left: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                )),
                width: (mediaSize.width - 40) / 2,
                height: (mediaSize.width - 20) / 2 - 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "필터 교체일",
                      style: TextStyle(
                        color: Colors.indigo[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text("${DateFormat("yyyy년 MM월 dd일").format(replaceDate)}"),
                    Text("${DateFormat("a hh:mm").format(replaceDate)}"),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            width: mediaSize.width - 40,
            height: (mediaSize.width - 20) / 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: filterImage,
                ),
                Expanded(
                  child: Container(
                    height: ((mediaSize.width - 20) / 4 - 20) / 2,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          width: 10,
                        ),
                        const Text("정수량:"),
                        Expanded(
                          flex: usageDay,
                          child: Container(
                            height: ((mediaSize.width - 20) / 4 - 20) / 6,
                            color: Colors.lightBlue[300],
                          ),
                        ),
                        Expanded(
                          flex: allDay - usageDay,
                          child: Container(
                            height: ((mediaSize.width - 20) / 4 - 20) / 6,
                            color: Colors.white,
                          ),
                        ),
                        Text("${(usageDay / allDay * 100).toInt()}%사용"),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _deleteFilter(int index) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _filters.removeAt(index);
        _filterWidgets.removeAt(index);
        _isEditable.removeAt(index);
        _descTextController.removeAt(index);
        _focus.removeAt(index);

        _saveToStorage();
      });
    });
  }

  _editFilter(BuildContext context, int index) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _filters[index] =
            _filters[index].copyWith(desc: _descTextController[index].text);
        _filterWidgets[index] = _makeFilterWidget(context, _filters[index]);
        _isEditable[index] = false;
        _focus[index].unfocus();

        _saveToStorage();
      });
    });
  }

  int _findIndex(String id) {
    for (int i = 0; i < _filters.length; i++)
      if (_filters[i].id == id) return i;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Size mediaSize = MediaQuery.of(context).size;

    return FutureBuilder<bool>(
      future: storage.ready,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!_initialized) {
            var filterDatas = storage.getItem("eins_filter");

            if (filterDatas != null) {
              _filters =
                  List<Filter>.from((filterDatas as List).map((e) => Filter(
                        id: e["id"],
                        productName: e["product_name"],
                        defaultDuration: e["default_duration"],
                        startDate: DateTime.parse(e["start_date"]),
                        replaceDate: DateTime.parse(e["replace_date"]),
                        desc: e["desc"],
                      )));

              _isEditable =
                  List<bool>.generate(_filters.length, (index) => false);

              _filterWidgets = List<Widget>.from(
                  _filters.map((e) => _makeFilterWidget(context, e)));

              _descTextController = List<TextEditingController>.generate(
                  _filters.length,
                  (index) => TextEditingController(text: _filters[index].desc));

              _focus = List<FocusNode>.generate(
                  _filters.length, (index) => FocusNode());
            }

            _filterWidgets.add(Container(
              width: mediaSize.width - 20,
              height: (mediaSize.width - 20) * 3 / 4,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 10,
                  color: Colors.indigo[300]!,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "새로운 필터 추가하기",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    iconSize: 60,
                    color: Colors.indigo[700],
                    icon: Icon(Icons.add_circle_outline_outlined),
                    onPressed: () {
                      _addFilter(context);
                    },
                  ),
                ],
              ),
            ));

            _initialized = true;
          }

          return Column(
            children: _filterWidgets,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _AndroidSessionDialog extends StatefulWidget {
  const _AndroidSessionDialog(this.alertMessage, this.handleTag);

  final String alertMessage;

  final Future<String?> Function(NfcTag tag) handleTag;

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
          final result = await widget.handleTag(tag);
          if (result == null) return;
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
