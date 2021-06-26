import 'dart:async';

import 'package:flutter/material.dart';

class EinsBanner extends StatefulWidget {
  final List<FadeInImage> einsBanners;

  const EinsBanner({Key? key, required this.einsBanners}) : super(key: key);

  @override
  _EinsBannerState createState() => _EinsBannerState();
}

class _EinsBannerState extends State<EinsBanner> {
  late PageController _pageController;
  late int _currentPage;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController(initialPage: widget.einsBanners.length * 100);
    _currentPage = widget.einsBanners.length * 100;
    _timer = Timer.periodic(Duration(milliseconds: 5200), (timer) {
      _currentPage++;
      _pageController.animateToPage(_currentPage,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;

    return Container(
      color: Colors.indigo[50],
      width: mediaSize.width,
      height: mediaSize.width * 0.4,
      child: Stack(
        children: [
          PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _timer.cancel();
                _timer = Timer.periodic(Duration(milliseconds: 5200), (timer) {
                  _currentPage++;
                  _pageController.animateToPage(_currentPage,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                });
              });
            },
            controller: _pageController,
            itemBuilder: (BuildContext context, index) =>
                widget.einsBanners[(index % widget.einsBanners.length)],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: mediaSize.width * 0.35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                    widget.einsBanners.length * 2 - 1, (index) {
                  if (index % 2 == 0) {
                    return Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index / 2 ==
                                (_currentPage % widget.einsBanners.length)
                            ? Colors.indigo
                            : Colors.indigo[100],
                      ),
                    );
                  } else {
                    return SizedBox(width: 10);
                  }
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
