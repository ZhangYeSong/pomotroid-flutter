import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

enum Period { focus, shortBreak, longBreak }

String formatDuration(int time) {
  int minutes = time ~/ 60;
  int seconds = time % 60;

  String formattedTime =
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  return formattedTime;
}

class TimeState extends ChangeNotifier {
  late Timer _timer;
  late Stopwatch _stopwatch;
  int totalTime = 0;
  int _countDownTime = 0;
  final cycle = [
    Period.focus,
    Period.shortBreak,
    Period.focus,
    Period.shortBreak,
    Period.focus,
    Period.shortBreak,
    Period.focus,
    Period.longBreak
  ];
  int cycleIndex = 0;

  TimeState() {
    totalTime = _getPeroidTotalTime();
    _countDownTime = totalTime;
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countDownTime = totalTime - _stopwatch.elapsed.inSeconds;
      notifyListeners();
      if (_countDownTime <= 0) {
        _nextPeriod();
      }
    });
  }

  void dispose() {
    _stopwatch.stop();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _stopwatch.start();
  }

  void _pauseTimer() {
    _stopwatch.stop();
  }

  void _resetTimer() {
    _stopwatch.stop();
    _stopwatch.reset();
    _countDownTime = totalTime;
    notifyListeners();
  }

  void _nextPeriod() {
    _stopwatch.reset();
    cycleIndex++;
    if (cycleIndex >= cycle.length) {
      cycleIndex = 0;
    }
    totalTime = _getPeroidTotalTime();
    _countDownTime = totalTime;
    notifyListeners();
  }

  String _getPeroidText() {
    switch (cycle[cycleIndex]) {
      case Period.focus:
        return 'FOCUS';
      case Period.shortBreak:
        return 'SHORT BREAK';
      case Period.longBreak:
        return 'LONG BREAK';
      default:
        return 'FOCUS';
    }
  }

  String _getPeroidInCycleText() {
    return '${cycleIndex ~/ 2 + 1}/${cycle.length ~/ 2}';
  }

  int _getPeroidTotalTime() {
    switch (cycle[cycleIndex]) {
      case Period.focus:
        return const Duration(minutes: 25).inSeconds;
      case Period.shortBreak:
        return const Duration(minutes: 5).inSeconds;
      case Period.longBreak:
        return const Duration(minutes: 15).inSeconds;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => TimeState(),
        child: MaterialApp(
          title: 'Pomotroid Flutter',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Pomotroid Flutter'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var timeState = context.watch<TimeState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WatchWiget(),
                Text(timeState._getPeroidText()),
              ],
            ),
          )),
          Visibility(
            visible: !timeState._stopwatch.isRunning,
            child: FloatingActionButton(
              onPressed: () => timeState._startTimer(),
              child: const Icon(Icons.start),
            ),
          ),
          Visibility(
            visible: timeState._stopwatch.isRunning,
            child: FloatingActionButton(
              onPressed: () => timeState._pauseTimer(),
              child: const Icon(Icons.pause),
            ),
          ),
          const SizedBox(height: 60),
          Row(
            children: [
              const SizedBox(width: 30),
              Column(
                children: [
                  Text(timeState._getPeroidInCycleText()),
                  FloatingActionButton(
                    onPressed: () => timeState._resetTimer(),
                    child: const Icon(Icons.reset_tv),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              FloatingActionButton(
                onPressed: () => timeState._nextPeriod(),
                child: const Icon(Icons.skip_next),
              ),
              const SizedBox(width: 30),
            ],
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}

class WatchWiget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var timeState = context.watch<TimeState>();
    return Text(
      formatDuration(timeState._countDownTime),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
