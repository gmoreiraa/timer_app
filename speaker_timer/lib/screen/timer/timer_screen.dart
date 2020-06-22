import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speaker_timer/animations/blink.dart';
import 'package:speaker_timer/controller/ad_mob.dart';
import 'package:speaker_timer/controller/status.dart';
import 'package:speaker_timer/screen/background/background.dart';
import 'package:speaker_timer/screen/background/widgets/crystal.dart';
import 'package:speaker_timer/screen/stopwatch/widgets/time_text.dart';
import 'package:speaker_timer/screen/timer/widgets/flutter_datetime_picker_lib/src/datetime_picker_theme.dart';
import 'widgets/flutter_datetime_picker_lib/flutter_datetime_picker.dart';

class Timer extends StatefulWidget {
  final PlayStatus otherPlayer;

  Timer(this.otherPlayer);

  @override
  _TimerNewState createState() => _TimerNewState();
}

class _TimerNewState extends State<Timer> with AutomaticKeepAliveClientMixin<Timer> {
  int millisecond;
  int repeatTimes;

  int dateTimeToMilliSecond(DateTime date){
    return date.second*1000 + date.minute*60000 + date.hour*1440000;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.infinity,
      height:double.infinity,
      color: Theme.of(context).backgroundColor,
      child: Consumer<PlayStatus>(
        builder: (context, player, child) {
          return Stack(
            children: <Widget>[
              player.isTimerSelected? 
              Container(color: Colors.transparent) 
              : Center(
                child: Crystal(
                  child: GestureDetector(
                    onTap: (){
                      // Close the APP Ad Banner due to UX while picking the Time
                      AppAds.removeBanner();

                      DatePicker.showTimePicker(context, showTitleActions: true,
                      onConfirm: (date,repeat) {
                        player.isTimerSelected = true;
                        millisecond = dateTimeToMilliSecond(date);
                        repeatTimes=repeat;
                      }, 
                      currentTime: DateTime.now(),
                      theme: DatePickerTheme(
                        backgroundColor: Theme.of(context).primaryColor,
                        itemStyle: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 18),
                        subTitleStyle: TextStyle(color: Theme.of(context).backgroundColor.withOpacity(0.5), fontSize: 14),
                        cancelStyle: TextStyle(color: Theme.of(context).backgroundColor.withOpacity(0.7), fontSize: 16),
                        doneStyle: TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
                      ),
                      );
                    },
                    child:Blink(child:Center(child:TimeText('00:00:00')))
                  )
                )
              ),
              player.isTimerSelected? 
              Background(widget.otherPlayer,'Timer',duration: millisecond)
              : IgnorePointer(child: Container(color: Colors.transparent)),
            ],
          );
        }
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}