import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    WidgetsFlutterBinding.ensureInitialized();
    // 必须加上这一行。
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(360, 478),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    windowManager.setAlwaysOnTop(true);
  }

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
  bool isPlaying = false;
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

  static AudioPlayer audioPlayer = AudioPlayer();
  static AudioPlayer notificationPlayer = AudioPlayer();

  TimeState() {
    totalTime = _getPeroidTotalTime();
    _countDownTime = totalTime;
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPlaying) {
        audioPlayer.play(AssetSource("audio/tick.mp3"));
      }
      _countDownTime = totalTime - _stopwatch.elapsed.inSeconds;
      notifyListeners();
      if (_countDownTime <= 0) {
        _nextPeriod();
        if (cycle[cycleIndex] == Period.focus) {
          notificationPlayer.play(AssetSource("alert-work.mp3"));
        } else if (cycle[cycleIndex] == Period.shortBreak) {
          notificationPlayer.play(AssetSource("alert-short-break.mp3"));
        } else if (cycle[cycleIndex] == Period.longBreak) {
          notificationPlayer.play(AssetSource("alert-long-break.mp3"));
        }
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
    isPlaying = true;
    notifyListeners();
  }

  void _pauseTimer() {
    _stopwatch.stop();
    isPlaying = false;
    notifyListeners();
  }

  void _resetTimer() {
    _stopwatch.stop();
    _stopwatch.reset();
    isPlaying = false;
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

  double getProgress() {
    return _countDownTime / totalTime;
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
            child: Stack(
              children: [
                Center(
                  child: WatchProgress(timeState.getProgress()),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WatchWiget(),
                      Text(timeState._getPeroidText()),
                    ],
                  ),
                )
              ],
            ),
          ),
          FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () => {
              if (timeState.isPlaying)
                {timeState._pauseTimer()}
              else
                {timeState._startTimer()}
            },
            child: Icon(
              timeState.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 10),
              Column(
                children: [
                  Text(timeState._getPeroidInCycleText()),
                  FloatingActionButton(
                    shape: const CircleBorder(),
                    onPressed: () => timeState._resetTimer(),
                    child: const Icon(Icons.reset_tv),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () => timeState._nextPeriod(),
                child: const Icon(Icons.skip_next),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 10)
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

class WatchProgressPainter extends CustomPainter {
  final double progress; // 进度值，范围为0到1之间

  WatchProgressPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    final progressAngle = 2 * math.pi * progress;

    final backgroundPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final foregroundPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progressAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class WatchProgress extends StatelessWidget {
  final double progress;

  WatchProgress(this.progress);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(200, 200),
      painter: WatchProgressPainter(progress),
    );
  }
}
