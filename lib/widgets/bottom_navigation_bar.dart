import 'package:eins_client/providers/youtube_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget bottomNavigationBar(
    BuildContext context, PageController controller, int page) {
  return Container(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
    height: 68,
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: page == 0 ? Colors.deepPurple[100] : Colors.white,
              ),
              child: Icon(
                Icons.home_outlined,
                size: 48,
                color: page == 0 ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        VerticalDivider(
          width: 2,
          thickness: 2,
          indent: 4,
          endIndent: 4,
          color: Colors.grey[300],
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              controller.jumpToPage(1);
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: page == 1 ? Colors.deepPurple[100] : Colors.white,
              ),
              child: Icon(
                Icons.info_outline,
                size: 48,
                color: page == 1 ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        VerticalDivider(
          width: 2,
          thickness: 2,
          indent: 4,
          endIndent: 4,
          color: Colors.grey[300],
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: page == 2 ? Colors.deepPurple[100] : Colors.white,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: page == 2 ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        VerticalDivider(
          width: 2,
          thickness: 2,
          indent: 4,
          endIndent: 4,
          color: Colors.grey[300],
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: page == 3 ? Colors.deepPurple[100] : Colors.white,
              ),
              child: Icon(
                Icons.perm_phone_msg_outlined,
                size: 48,
                color: page == 3 ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
