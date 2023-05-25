import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timer_app/time_up_screen.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const TimerClass());
}

class TimerClass extends StatelessWidget {
  const TimerClass({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TimerHome(),
    );
  }
}

class TimerHome extends StatefulWidget {
  const TimerHome({Key? key}) : super(key: key);
  @override
  State<TimerHome> createState() => _TimerHomeState();
}

class _TimerHomeState extends State<TimerHome> with TickerProviderStateMixin {
  int initSecond = 0, initMinute = 0, initHour = 0;
  int _counterSecond = 0, _counterMinute = 0, _counterHour = 0;
  String secondString = '00', minuteString = '00', hourString = '00';
  late Timer timerDown;
  int totalSecond = 0;
  bool isPaused = true;
  bool isInit = true;

  late AnimationController controller;
  final player = AudioPlayer();

  void updateCounterStrings() {
    setState(() {
      if (_counterSecond < 10) {
        secondString = '0$_counterSecond';
      }
      else {
        secondString = _counterSecond.toString();
      }
      if (_counterMinute < 10) {
        minuteString = '0$_counterMinute';
      }
      else {
        minuteString = _counterMinute.toString();
      }
      if (_counterHour < 10) {
        hourString = '0$_counterHour';
      }
      else {
        hourString = _counterHour.toString();
      }
    });
  }

  void updateCounterUnits() {
    setState(() {
      if (_counterSecond == 0) {
        _counterSecond = 59;
        if (_counterMinute == 0) {
          _counterMinute = 0;
          if (_counterHour == 0) {
            _counterSecond = 0;
            player.setVolume(100);
            player.play();
            timeIsUp();
          }
          else {
            _counterHour--;
          }
        }
        else {
          _counterMinute--;
        }
      }
      else {
        _counterSecond--;
      }
    });
  }

  void manageClock() {
      initMinute += (initSecond ~/ 60);
      initSecond %= 60;
      initHour += (initMinute ~/ 60);
      initMinute %= 60;
      initHour %= 24;
  }

  void resumeTimer() {
    isInit = false;
    timerDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        isPaused = false;
        controller.forward(from: controller.value);
        updateCounterUnits();
        updateCounterStrings();
      });
    });
  }

  void pauseTimer() {
    isInit = false;
    setState(() {
      isPaused = true;
      timerDown.cancel();
      controller.stop();
    });
  }

  void resetTimer() {
    setState(() {
      isPaused = true;

      _counterSecond = initSecond;
      _counterMinute = initMinute;
      _counterHour = initHour;

      updateCounterStrings();

      controller.reset();
      timerDown.cancel();
    });
  }

  void initTimer() async {
    final duration = await player.setAsset('assets/Techno Timer.mp3');
    setState(() {
      isInit = true;
      manageClock();
      _counterSecond = initSecond;
      _counterMinute = initMinute;
      _counterHour = initHour;
      totalSecond = 0;
      totalSecond += _counterSecond;
      totalSecond += _counterMinute * 60;
      totalSecond += _counterHour * 60 * 60;
      updateCounterStrings();
      controller = AnimationController(
        /// [AnimationController]s can be created with `vsync: this` because of
        /// [TickerProviderStateMixin].
        vsync: this,
        duration: Duration(seconds: totalSecond),
      )..addListener(() {
        setState(() {});
      });
      resetTimer();
    });
  }

  void timeIsUp() {
    showDialog(context: context, barrierDismissible: false, builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xff1d1f2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        titleTextStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        icon: const Icon(Icons.timer,
          size: 50,
          color: Colors.blue,
        ),
        title: const Text(
          'Time\'s Up!',
        ),
        actions: [
          TextButton(onPressed: () {
            player.stop();
            Navigator.of(context).pop(); isInit = true;},
              child: const Icon(
                Icons.close_rounded,
                size: 30,
                color: Colors.blue,
              )
          )
        ],
      );
    });
    initTimer();
  }

  @override
  void initState() {
    timerDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1d1f2e),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Text(
          'Timer',
          style: TextStyle(color: Colors.white,),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 360,
            width: 360,
            child: CircularProgressIndicator(
              value: controller.value,
              backgroundColor: Colors.grey,
              color: Colors.blue,
              strokeWidth: 30,
              semanticsLabel: 'Circular progress indicator',
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isInit) Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 50,),
                    NumberPicker(
                        minValue: 0,
                        maxValue: 24,
                        value: initHour,
                        zeroPad: true,
                        itemHeight: 60,
                        itemWidth: 60,
                        textStyle: GoogleFonts.roboto(
                          color: Colors.grey,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                        selectedTextStyle: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                        onChanged: (value) {
                          setState(() {
                            initHour = value;
                            initTimer();
                          });
                        }
                    ),
                    const Spacer(flex: 1,),
                    Text(
                        ':',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(flex: 1,),
                    NumberPicker(
                        minValue: 0,
                        maxValue: 60,
                        value: initMinute,
                        zeroPad: true,
                        itemHeight: 60,
                        itemWidth: 60,
                        textStyle: GoogleFonts.roboto(
                          color: Colors.grey,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                        selectedTextStyle: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                        onChanged: (value) {
                          setState(() {
                            initMinute = value;
                            initTimer();
                          });
                        }
                    ),
                    const Spacer(flex: 1,),
                    Text(
                      ':',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(flex: 1,),
                    NumberPicker(
                        minValue: 0,
                        maxValue: 60,
                        value: initSecond,
                        // infiniteLoop: true,
                        zeroPad: true,
                        itemHeight: 60,
                        itemWidth: 60,
                        textStyle: GoogleFonts.roboto(
                          color: Colors.grey,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                        selectedTextStyle: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                        onChanged: (value) {
                          setState(() {
                            initSecond = value;
                            initTimer();
                          });
                        }
                    ),
                    const Spacer(flex: 50,),
                  ],
                ),
              ),
              if (!isInit) Center(
                child: Text(
                  '$hourString:$minuteString:$secondString',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 8,),
                    if(isPaused)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Icon(
                          Icons.play_arrow_sharp,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          resumeTimer();
                          // Navigator.of(context).push(
                          //   MaterialPageRoute (
                          //     builder: (BuildContext context) => const TimeUpClass(),
                          //   ),
                          // );
                        },
                    ),
                    if(isPaused)
                      const Spacer(flex: 1,),

                    if(!isPaused)
                      ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.pause,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        pauseTimer();
                      },
                    ),
                    if(!isPaused)
                      const Spacer(flex: 1,),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.replay,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        resetTimer();
                      },
                    ),
                    const Spacer(flex: 1,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.stop,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        initTimer();
                      },
                    ),
                    const Spacer(flex: 8,),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}