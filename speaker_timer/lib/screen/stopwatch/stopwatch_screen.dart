import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:speaker_timer/controller/status.dart';
import 'package:speaker_timer/animations/expand_animation.dart';
import 'package:speaker_timer/screen/stopwatch/widgets/button.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:vibration/vibration.dart';

class StopWatch extends StatefulWidget {
  final PlayStatus player;
  final int duration;
  final bool isTimer;

  StopWatch(this.player,this.duration,this.isTimer);
  @override
  _StopWatchNewState createState() => _StopWatchNewState();
}

class _StopWatchNewState extends State<StopWatch>
    with SingleTickerProviderStateMixin {
  final StopWatchTimer _stopWatchNewTimer = StopWatchTimer();
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));

    _animation = Tween<double>(begin: 0, end: 30).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack));

    _animationController.forward();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchNewTimer.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String getDisplayHour(int value) {
      final m = (value / 1440000).floor();
      return m.toString().padLeft(2, '0');
    }
    
    // Display Time for The Timer mode [hour : minute : second]
    String getDisplayTime(int value){
      String result = '';

      result += '${getDisplayHour(value)}';
      result += ':';
      result += '${StopWatchTimer.getDisplayTimeMinute(value)}';
      result += ':';
      result += '${StopWatchTimer.getDisplayTimeSecond(value)}';
      return result;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /// Display stop watch time
          StreamBuilder(
              initialData: 0,
              stream: _stopWatchNewTimer.rawTime,
              builder: (context, snapshot) {
                if(widget.isTimer){
                  // Vibrate when the Timer ends
                  if(widget.duration - snapshot.data==0)
                    Vibration.vibrate(pattern: [150, 150, 100],intensities: [100,0,75],repeat: 2);
                }else{
                  // Vibrate every time the time is multiple of the widget.duration parameter
                  if(snapshot.data%widget.duration==0&&snapshot.data!=0)
                    Vibration.vibrate(pattern: [150, 150, 100],intensities: [100,0,75],repeat: 2);
                }
                return Text(
                  widget.isTimer 
                  ? getDisplayTime(widget.duration - snapshot.data)
                  : StopWatchTimer.getDisplayTime(snapshot.data),
                  style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 45.0),
                );
              }),
          SizedBox(
            height: 20.0,
          ),

          /// BUTTONS
          Stack(
            children: <Widget>[
              Opacity(
                opacity: 0,
                child: SizedBox(
                  height: 40,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _stopWatchNewTimer.isRunning()
                      ?
                      //Pause Button
                      ExpandAnimation(
                          fixWidth: true,
                          child: Button(
                              onTap: () {
                                _pauseSetState(widget.player);
                              },
                              type: 'pause'),
                          animation: _animation)
                      : widget.player.reset
                          ?
                          //Play Button
                          ExpandAnimation(
                              fixHeight: true,
                              child: Button(
                                  onTap: () {
                                    _playSetState(widget.player);
                                  },
                                  type: 'play'),
                              animation: _animation,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                //Play Button
                                ExpandAnimation(
                                    fixHeight: true,
                                    child: Button(
                                        onTap: () {
                                          _playSetState(widget.player);
                                        },
                                        type: 'play'),
                                    animation: _animation),

                                //Spacing the Widgets
                                SizedBox(
                                  width: 45,
                                ),

                                //Reset Button
                                ExpandAnimation(
                                    fixHeight: true,
                                    child: Button(
                                        onTap: () async {
                                          _resetSetState(widget.player);
                                        },
                                        type: 'reset'),
                                    animation: _animation),
                              ],
                            )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _playSetState(PlayStatus playStatus) {
    _animationController.reset();
    playStatus.isPlaying = true;
    playStatus.reset = false;
    _stopWatchNewTimer.onExecute.add(StopWatchExecute.start);
    _animationController.forward();
  }

  void _pauseSetState(PlayStatus playStatus) {
    _animationController.reset();
    playStatus.isPlaying = false;
    _stopWatchNewTimer.onExecute.add(StopWatchExecute.stop);
    _animationController.forward();
  }

  void _resetSetState(PlayStatus playStatus) {
    _animationController.reset();
    playStatus.isPlaying = false;
    playStatus.reset = true;
    _stopWatchNewTimer.onExecute.add(StopWatchExecute.reset);
    _animationController.forward();
  }
}