import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class TimerWidget extends StatefulWidget {
  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late final StreamController<Duration> _streamController;
  late final Stream<Duration> _durationStream;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<Duration>();
    _durationStream = _streamController.stream;
    _startTimer();
  }

  void _startTimer() {
    const duration =
        Duration(minutes: 5); // or whatever your initial duration is
    var remaining = duration;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining = remaining - const Duration(seconds: 1);
      if (remaining.inSeconds <= 0) {
        timer.cancel();
        _streamController.add(Duration.zero);
      } else {
        _streamController.add(remaining);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
        stream: _durationStream,
        builder: (context, snapshot) {
          String timeToShow = "00:00";
          if (snapshot.hasData) {
            int remainingDuration = snapshot.data?.inSeconds ?? 0;
            int minutes = remainingDuration ~/ 60;
            int seconds = remainingDuration % 60;
            timeToShow = "$minutes:${seconds < 10 ? '0' : ''}$seconds";
          }
          return Text(
            timeToShow,
            style: GoogleFonts.geo(
              fontSize: 50,
              color: Colors.white,
            ),
          );
        });
  }
}
