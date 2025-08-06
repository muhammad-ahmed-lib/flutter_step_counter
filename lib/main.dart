import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StepCounterScreen(),
    );
  }
}

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?';
  int _steps = 0;
  String _error = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Request permission first
    final status = await Permission.activityRecognition.request();
    if (!status.isGranted) {
      setState(() {
        _error = 'Permission not granted';
      });
      return;
    }

    try {
      _stepCountStream = Pedometer.stepCountStream;
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

      _stepCountStream.listen((StepCount event) {
        setState(() {
          _steps = event.steps;
        });
      }).onError((error) {
        setState(() {
          _error = error.toString();
        });
      });

      _pedestrianStatusStream.listen((PedestrianStatus event) {
        setState(() {
          _status = event.status;
        });
      }).onError((error) {
        setState(() {
          _error = error.toString();
        });
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.directions_walk, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Steps Taken',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '$_steps',
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 40),
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}