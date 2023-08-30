import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

String formatDuration(Duration duration) {
  int minutes = duration.inMinutes;
  int seconds = duration.inSeconds % 60;

  String formattedTime =
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  return formattedTime;
}

class TimeState extends ChangeNotifier {
  late Timer _timer;
  late Stopwatch _stopwatch;
  Duration _elapsedTime = Duration.zero;

  TimeState() {
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime = _stopwatch.elapsed;
      notifyListeners();
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

  void _stopTimer() {
    _stopwatch.stop();
    _timer.cancel();
  }

  void _resetTimer() {
    _stopwatch.reset();
    _elapsedTime = Duration.zero;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => TimeState(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            WatchWiget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => timeState._startTimer(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WatchWiget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var timeState = context.watch<TimeState>();
    return Text(
      formatDuration(timeState._elapsedTime),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
