import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:speaker_timer/controller/ad_mob.dart';
import 'package:speaker_timer/screen/config.dart';

class CustomAppBar extends StatefulWidget {
  final PageController pageController;

  CustomAppBar(this.pageController);
  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation scrollAnimation;
  Animation arrowAnimation;
  int pageIndex = 1;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    arrowAnimation = Tween<double>(begin: 0, end: -math.pi).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutSine,
            reverseCurve: Curves.easeInSine));
    widget.pageController.addListener(() {
      setState(() {
        pageIndex = widget.pageController.page.round();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scrollAnimation = Tween<double>(
            begin: MediaQuery.of(context).size.width / 5.5,
            end: MediaQuery.of(context).size.width / 2.0)
        .animate(CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutSine,
            reverseCurve: Curves.easeInSine));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color accentColor = Theme.of(context).accentColor;
    Color buttonColor = Theme.of(context).buttonColor;
    Color backgroundColor = Theme.of(context).backgroundColor;

    Widget _barButton(IconData icon, int index,{EdgeInsets margin,Function onTap}) => 
    GestureDetector(
          child: Container(
            margin: margin?? EdgeInsets.symmetric(horizontal: controller.isDismissed ? 0 : 7),
            height: size.height / 16,
            width: size.width / 7,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: index != pageIndex ? backgroundColor : Theme.of(context).hintColor),
            child: Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: index == pageIndex ? backgroundColor : buttonColor
                ),
                if(controller.isCompleted)
                  Text('Textooo')
              ],
            )),
          onTap:onTap?? () {
            widget.pageController.animateToPage(index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic);
          },
        );

    Widget _appIcon() => Padding(
          padding: const EdgeInsets.only(top: 5),
          child: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Transform.rotate(
                  angle: arrowAnimation.value,
                  child: Icon(
                    Icons.arrow_right,
                    color: accentColor,
                  ),
                ),
                Image.asset(
                  'assets/hourglass_icon.png',
                  width: size.width / 12,
                  height: size.height / 14,
                ),
              ],
            ),
            onTap: () {
              // Close the APP Ad Banner due to UX while picking the Time
              AppAds.removeBanner();
              
              if (!controller.isCompleted)
                controller.forward();
              else
                controller.reverse();
            },
          ),
        );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          height: size.height,
          width: scrollAnimation.value,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black54,
                    spreadRadius: controller.isDismissed ? 0 : size.width / 1.2)
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: controller.isDismissed
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: <Widget>[
              _appIcon(),
              Divider(),
              _barButton(Icons.av_timer, 0),
              _barButton(Icons.hourglass_empty, 1),
              _barButton(Icons.settings,3,
                margin: EdgeInsets.only(left: controller.isDismissed ? 0 : 3.5,
                                        right: controller.isDismissed ? 0 : 3.5,
                                        top: 300),
                  onTap: (){
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Configuration(),),
                    );
                  })
            ],
          ),
        );
      },
    );
  }
}