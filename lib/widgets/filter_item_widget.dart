import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eins_client/models/filter_model.dart';
import 'package:eins_client/providers/my_filter_provider.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  double _opacity = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    e = context.read<MyFilterProvider>().filters[widget.index];
    startDate = e.startDate;
    replaceDate = e.replaceDate;
    allDay = replaceDate.difference(startDate).inDays;
    usageDay = DateTime.now().difference(startDate).inDays;
    filterImage =
        context.read<ProductProvider>().productImageByName(e.productName);

    _isEditable = false;
    _descTextController = TextEditingController(text: e.desc);
    _focus = FocusNode();

    if (usageDay / allDay >= 0.9) {
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {
          _opacity = _opacity == 0 ? 1 : 0;
        });
      });
    }
  }

  @override
  void dispose() {
    _descTextController.dispose();
    _focus.dispose();
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final MyFilterProvider myFilterProv = context.read<MyFilterProvider>();
    final originalText = _descTextController.text;

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
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            height: 1,
                            fontWeight: FontWeight.bold),
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
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                        color: Colors.deepPurple[300],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    color: Colors.white)),
                                            counterText: "",
                                          ),
                                          scrollPadding:
                                              const EdgeInsets.all(0),
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
                                              color: Colors.white,
                                              fontSize: 24,
                                              height: 1),
                                        ),
                                ),
                              ),
                              _isEditable
                                  ? InkWell(
                                      child: Icon(
                                        Icons.check,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          myFilterProv
                                              .editFilter(widget.index,
                                                  _descTextController.text)
                                              .then((_) {
                                            setState(() {
                                              _isEditable = false;
                                              _focus.unfocus();
                                            });
                                          }, onError: (e) {
                                            errorDialog(context,
                                                Exception("필터 이름을 다시 설정해주세요."));

                                            setState(() {
                                              _descTextController.text =
                                                  originalText;
                                              _isEditable = false;
                                              _focus.unfocus();
                                            });
                                          });
                                        });
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
                                          _isEditable = true;
                                          _focus.requestFocus();
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
                                  myFilterProv.deleteFilter(widget.index);
                                },
                              ),
                              const SizedBox(
                                width: 10,
                                height: 30,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              AnimatedOpacity(
                                opacity: usageDay / allDay < 0.9 ? 1 : _opacity,
                                duration: usageDay / allDay < 0.9
                                    ? Duration.zero
                                    : Duration(seconds: 1),
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      width: ((mediaSize.width - 80) * 3 / 4 -
                                              30) /
                                          2,
                                      height:
                                          (mediaSize.width - 80) * 3 / 4 - 30,
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
                                            (mediaSize.width - 80) * 3 / 4 -
                                                30),
                                        child: Container(
                                          width:
                                              ((mediaSize.width - 80) * 3 / 4 -
                                                      30) /
                                                  2,
                                          height:
                                              (mediaSize.width - 80) * 3 / 4 -
                                                  30,
                                        ),
                                      ),
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
                              ),
                              Container(
                                width: mediaSize.width -
                                    80 -
                                    ((mediaSize.width - 80) * 3 / 4 - 30) / 2,
                                height: (mediaSize.width - 80) * 3 / 4 - 30,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(
                                      "정수량",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          height: 1),
                                    ),
                                    Text.rich(TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text:
                                              "${(usageDay / allDay * 100).toInt()}%",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 36,
                                              height: 1),
                                        ),
                                        TextSpan(
                                          text: "사용",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              height: 1),
                                        ),
                                      ],
                                    )),
                                    Text(
                                      "마지막 교체\n${usageDay ~/ 30}개월 전",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          height: 1),
                                    ),
                                    Text(
                                      "다음 교체\n${(allDay - usageDay) ~/ 30}개월 후",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          height: 1),
                                    ),
                                  ],
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
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1),
                                ),
                                Text(
                                  "${DateFormat("yyyy년 MM월 dd일").format(startDate)}",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1),
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
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1),
                                ),
                                Text(
                                  "${DateFormat("yyyy년 MM월 dd일").format(replaceDate)}",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1),
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