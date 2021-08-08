import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eins_client/constants/color_constant.dart';
import 'package:eins_client/models/filter_model.dart';
import 'package:eins_client/providers/local_storage_provider.dart';
import 'package:eins_client/providers/my_filter_provider.dart';
import 'package:eins_client/providers/product_provider.dart';
import 'package:eins_client/widgets/custom_dotted_line.dart';
import 'package:eins_client/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final MyFilterProvider myFilterProv = context.read<MyFilterProvider>();
    final originalText = _descTextController.text;

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
                          ? InkWell(
                              child: Icon(
                                Icons.check,
                                size: 24,
                                color: kBackgroundColor,
                              ),
                              onTap: () {
                                myFilterProv
                                    .editFilter(
                                        widget.index, _descTextController.text)
                                    .then((_) {
                                  setState(() {
                                    _isEditable = false;
                                    _focus.unfocus();
                                  });
                                }, onError: (e) {
                                  errorDialog(context, "필터 이름을 다시 설정해주세요.");

                                  setState(() {
                                    _descTextController.text = originalText;
                                    _isEditable = false;
                                    _focus.unfocus();
                                    if (context
                                        .read<LocalStorageProvider>()
                                        .isNotificated) {
                                      context
                                          .read<MyFilterProvider>()
                                          .dailyAtTimeNotification();
                                    }
                                  });
                                });
                              },
                            )
                          : InkWell(
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
                      InkWell(
                        child: Icon(
                          Icons.delete,
                          size: 24,
                          color: kBackgroundColor,
                        ),
                        onTap: () {
                          myFilterProv.deleteFilter(widget.index);
                          if (context
                              .read<LocalStorageProvider>()
                              .isNotificated) {
                            context
                                .read<MyFilterProvider>()
                                .dailyAtTimeNotification();
                          }
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
                                  child: Row(
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
                                  child: Row(
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
