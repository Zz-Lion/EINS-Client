import 'package:eins_client/constants/color_constant.dart';
import 'package:flutter/material.dart';

enum CustomAxis { row, column }

Widget customDottedLine(CustomAxis axis) {
  if (axis == CustomAxis.row) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...List<Widget>.generate((constraints.maxWidth ~/ 10) * 2,
              (int index) {
            if (index % 2 == 0) {
              return Container(
                width: 5,
                height: 2,
                color: kBackgroundColor,
              );
            } else {
              return const SizedBox(width: 5);
            }
          }),
          Visibility(
            visible: constraints.maxWidth % 10 != 0,
            child: Container(
              width:
                  constraints.maxWidth % 10 > 5 ? 5 : constraints.maxWidth % 10,
              height: 2,
              color: kBackgroundColor,
            ),
          ),
          Visibility(
            visible: constraints.maxWidth % 10 > 5,
            child: SizedBox(width: constraints.maxWidth % 10 - 5),
          ),
        ],
      );
    });
  } else {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          ...List<Widget>.generate((constraints.maxHeight ~/ 10) * 2,
              (int index) {
            if (index % 2 == 0) {
              return Container(
                width: 2,
                height: 5,
                color: kBackgroundColor,
              );
            } else {
              return const SizedBox(height: 5);
            }
          }),
          Visibility(
            visible: constraints.maxHeight % 10 != 0,
            child: Container(
              width: 2,
              height: constraints.maxHeight % 10 > 5
                  ? 5
                  : constraints.maxHeight % 10,
              color: kBackgroundColor,
            ),
          ),
          Visibility(
            visible: constraints.maxHeight % 10 > 5,
            child: SizedBox(width: constraints.maxHeight % 10 - 5),
          ),
        ],
      );
    });
  }
}
