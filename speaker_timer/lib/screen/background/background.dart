import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speaker_timer/controller/ad_mob.dart';
import 'package:speaker_timer/controller/status.dart';
import 'package:speaker_timer/screen/background/widgets/crystal.dart';
import 'package:speaker_timer/screen/background/widgets/sand.dart';
import 'package:speaker_timer/screen/background/widgets/sand_fall.dart';
import 'package:speaker_timer/screen/stopwatch/stopwatch_screen.dart';

class Background extends StatefulWidget {
  //The Clock's duration
  final int duration;
  final int repeat;
  final int rest;
  final String title;
  final PlayStatus otherPlayer;

  Background(this.otherPlayer,this.title,{this.duration = 20000,this.repeat,this.rest});

  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends State<Background>
    with SingleTickerProviderStateMixin<Background>,
    AutomaticKeepAliveClientMixin<Background> {

  AnimationController controller;
  Animation<double> heightSandTranslation;
  Animation<double> heightSandAnimation;
  Animation<double> topSandAnimation;
  Animation<double> bottomSandAnimation;
  Animation<double> widthSandAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration));
    heightSandAnimation = Tween<double>(begin: 1.0, end: 0.25)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    heightSandTranslation = Tween<double>(begin: -0.4, end: -1.2)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    bottomSandAnimation = Tween<double>(begin: 1.0, end: -0.8)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    widthSandAnimation = Tween<double>(begin: 0.4, end: 2.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Interval(0.9, 1.0, curve: Curves.easeOut)));
    controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    topSandAnimation =
        Tween<double>(begin: 0, end: MediaQuery.of(context).size.width / 6.0)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    print(size.width);
    print(size.height);

    final Image img = Image.asset(
      'assets/hourglass.png',
      fit: BoxFit.fill,
      width: 2.0 / 3.0 * size.width,
      height: size.height * 0.8,
    );

    return Consumer<PlayStatus>(
      builder: (context, player, child) {
        //It controls the ads to don't display banners while any timer is running
        bool shouldShowBanner = !((player?.isPlaying)??true)&&!((widget.otherPlayer?.isPlaying)??true);

        if(!player.isRestRunning){
          if (player.isPlaying) {
            controller.repeat();
          } else if (player.reset) {
            controller.reset();
          } else {
            controller.stop();
          }
        }else
          controller.stop();
        
        if(shouldShowBanner)
          AppAds.showBanner(state: this, anchorOffset: 5.0);
        else
          AppAds.removeBanner();

        return Container(
            color: Theme.of(context).backgroundColor,
            width: size.width,
            height: size.height,
            child: Stack(
              children: <Widget>[
                // Positioned and Transform are two different ways to move
                // any widget. However, Positioned is specific for a Stack case.
                Positioned(
                  top: 450,
                  left: 191,
                  //Animates the SandFall effect
                  child: AnimatedBuilder(
                      animation: controller,
                      builder: (_, child) {
                        return SizedBox(
                          width: 50,
                          height: size.height / 3.8,
                          child: CustomPaint(
                            painter: SandFall(player,context),
                          ),
                        );
                      }),
                ),

                //Animates the bottom Sand part of the Hourglass
                AnimatedBuilder(
                  animation: bottomSandAnimation,
                  builder: (BuildContext context, Widget child) {
                    return Transform(
                      transform: Matrix4.translationValues(
                          size.width / 10.0, size.height / 4.77, 0),
                      child: Center(
                        child: SizedBox(
                          width: size.width / 1.5,
                          height: size.height / 2.3,
                          child: ClipPath(
                            clipper: Sand(bottomSandAnimation.value, true,
                                width: widthSandAnimation.value),
                            child: Image.asset(
                              'assets/sand_bottom.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                //Animates the top Sand part of the Hourglass
                AnimatedBuilder(
                  animation: topSandAnimation,
                  builder: (BuildContext context, Widget child) {
                    return RotatedBox(
                      quarterTurns: 2,
                      child: Transform(
                        transform: Matrix4.translationValues(-size.width / 10.0,
                            size.height / 4.77 * heightSandAnimation.value, 0),
                        child: Center(
                          child: SizedBox(
                            width: size.width / 1.5,
                            height:
                                size.height / 2.3 * heightSandAnimation.value,
                            child: ClipPath(
                              clipper: Sand(heightSandTranslation.value, false,
                                  width: topSandAnimation.value),
                              child: Image.asset(
                                'assets/sand_top.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                //Display the Hourglass image
                Container(
                  height: size.height,
                  width: size.width,
                  padding: EdgeInsets.only(left: size.width * 0.2),
                  child: img,
                ),

                //The middle part of the Hourglass
                Center(
                  child: Crystal(
                    color: player.isRestRunning? 
                      Theme.of(context).accentColor
                      :Theme.of(context).primaryColor,
                    child: StopWatch(player,widget.otherPlayer,widget.duration,widget.title,
                      repeat: widget.repeat, rest:widget.rest),
                  )
                ),
              ],
            ));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
