import 'package:eins_client/constants/color_constant.dart';
import 'package:eins_client/providers/youtube_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

Widget bottomNavigationBar(
    BuildContext context, PageController controller, int page) {
  return Container(
    margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
    height: 68,
    decoration: BoxDecoration(
      color: kBackgroundColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 10,
        ),
      ],
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<YoutubeProvider>().pauseAllController();
              controller.jumpToPage(0);
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 4),
                  SvgPicture.asset(
                    'assets/icons/home.svg',
                    width: 24,
                    height: 24,
                    color: page == 0 ? kPrimaryColor : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "홈",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      color: page == 0 ? kPrimaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              controller.jumpToPage(1);
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 4),
                  SvgPicture.asset(
                    'assets/icons/info.svg',
                    width: 24,
                    height: 24,
                    color: page == 1 ? kPrimaryColor : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "제품",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      color: page == 1 ? kPrimaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<YoutubeProvider>().pauseAllController();
              controller.jumpToPage(2);
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 4),
                  SvgPicture.asset(
                    'assets/icons/sale.svg',
                    width: 24,
                    height: 24,
                    color: page == 2 ? kPrimaryColor : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "필터구입",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      color: page == 2 ? kPrimaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<YoutubeProvider>().pauseAllController();
              controller.jumpToPage(3);
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 4),
                  SvgPicture.asset(
                    'assets/icons/customer.svg',
                    width: 24,
                    height: 24,
                    color: page == 3 ? kPrimaryColor : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "고객센터",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      color: page == 3 ? kPrimaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
