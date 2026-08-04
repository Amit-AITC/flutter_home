import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  String _previousDigits = '0';

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  Set<int> _changedIndices = {};
  bool _isGroupAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    final newCounter = _counter + 1;
    final oldReversed = _previousDigits.split('').reversed.toList();
    final newReversed = '$newCounter'.split('').reversed.toList();

    // Compare digit-by-digit from the right (place value), so digit count
    // changes (9 -> 10) don't misalign the comparison.
    final changed = <int>{};
    for (int i = 0; i < newReversed.length; i++) {
      final oldChar = i < oldReversed.length ? oldReversed[i] : null;
      if (oldChar != newReversed[i]) {
        changed.add(i);
      }
    }

    setState(() {
      _counter = newCounter;
      _previousDigits = '$newCounter';
      _changedIndices = changed;
      _isGroupAnimation = changed.length > 1;
    });

    _controller.forward(from: 0);
  }

  void _decrementCounter() {
    if (_counter > 0) {
      final newCounter = _counter - 1;
      final oldReversed = _previousDigits.split('').reversed.toList();
      final newReversed = '$newCounter'.split('').reversed.toList();

      final changed = <int>{};
      for (int i = 0; i < newReversed.length; i++) {
        final oldChar = i < oldReversed.length ? oldReversed[i] : null;
        if (oldChar != newReversed[i]) {
          changed.add(i);
        }
      }

      setState(() {
        _counter = newCounter;
        _previousDigits = '$newCounter';
        _changedIndices = changed;
        _isGroupAnimation = changed.length > 1;
      });

      _controller.forward(from: 0);
    }
  }

  Widget _buildAnimatedNumber(String numberStr) {
    final reversedChars = numberStr.split('').reversed.toList();

    final digitWidgets = List<Widget>.generate(reversedChars.length, (i) {
      final text = Text(
        reversedChars[i],
        style: Theme.of(context).textTheme.headlineMedium,
      );

      final animateThisDigit =
          !_isGroupAnimation && _changedIndices.contains(i);

      return animateThisDigit
          ? ScaleTransition(scale: _scaleAnimation, child: text)
          : text;
    });

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: digitWidgets.reversed.toList(),
    );

    return _isGroupAnimation
        ? ScaleTransition(scale: _scaleAnimation, child: row)
        : row;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            _buildAnimatedNumber('$_counter'),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: FloatingActionButton(
              onPressed: _decrementCounter,
              tooltip: 'Decrement',
              child: const Icon(Icons.remove),
            ),
          ),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
