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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                      widget.einsBanners.length,
                      (index) => Expanded(
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: index ==
                                        (_currentPage %
                                            widget.einsBanners.length)
                                    ? Colors.indigo[900]
                                    : Colors.indigo[100],
                              ),
                            ),
                          )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
