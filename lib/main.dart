import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sorting_visulalization/paints/bars.dart';
import 'package:sorting_visulalization/paints/platform.dart';
import 'package:sorting_visulalization/sotring_algorithms/bubble_sort.dart';

StreamController<List<int>> streamController = StreamController();
List<int> numbers = [];
var width;
String currentSortAlgo = 'bubble';
double sampleSize = 320;
bool isSorted = false;
bool isSorting = false;
int speed = 0;
int duration = 1500;
GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
Duration getDuration() {
  return Duration(microseconds: duration);
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sampleSize = MediaQuery.of(context).size.width / 2;
    for (int i = 0; i < sampleSize; ++i) {
      numbers.add(Random().nextInt(500));
    }
    setState(() {});
  }

  reset() {
    isSorted = false;
    numbers = [];
    for (int i = 0; i < sampleSize; ++i) {
      numbers.add(Random().nextInt(500));
    }
    streamController.add(numbers);
  }

  setSortAlgo(String type) {
    setState(() {
      currentSortAlgo = type;
    });
  }

  checkAndResetIfSorted() async {
    if (isSorted) {
      reset();
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  String getTitle() {
    switch (currentSortAlgo) {
      case "bubble":
        return "Bubble Sort";
        break;
    }
    return "done";
  }

  changeSpeed() {
    if (speed >= 3) {
      speed = 0;
      duration = 1500;
    } else {
      speed++;
      duration = duration ~/ 2;
    }

    print(speed.toString() + " " + duration.toString());
    setState(() {});
  }

  sort() async {
    setState(() {
      isSorting = true;
    });

    await checkAndResetIfSorted();

    Stopwatch stopwatch = new Stopwatch()..start();

    switch (currentSortAlgo) {
      case "bubble":
        await bubbleSort();
        break;
    }

    stopwatch.stop();

    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          "Sorting completed in ${stopwatch.elapsed.inMilliseconds} ms.",
        ),
      ),
    );
    setState(() {
      isSorting = false;
      isSorted = true;
    });
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(getTitle()),
        backgroundColor: Color(0xFF0E4D64),
        actions: <Widget>[
          PopupMenuButton<String>(
            initialValue: currentSortAlgo,
            itemBuilder: (ctx) {
              return [
                PopupMenuItem(
                  value: 'bubble',
                  child: Text("Bubble Sort"),
                ),
              ];
            },
            onSelected: (String value) {
              reset();
              setSortAlgo(value);
            },
          ),
        ],
      ),
      body: CustomPaint(
        painter: Platform(),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(top: 0.0),
            child: StreamBuilder<Object>(
                initialData: numbers,
                stream: streamController.stream,
                builder: (context, snapshot) {
                  List<int> numbers = snapshot.data;
                  int counter = 0;
                  width = MediaQuery.of(context).size.width;
                  return Row(
                    children: numbers.map((int num) {
                      counter++;
                      return Container(
                        child: CustomPaint(
                          painter: BarPainter(
                              index: counter,
                              value: num,
                              width: MediaQuery.of(context).size.width /
                                  sampleSize),
                        ),
                      );
                    }).toList(),
                  );
                }),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            Expanded(
                child: FlatButton(
                    onPressed: isSorting
                        ? null
                        : () {
                            reset();
                            setSortAlgo(currentSortAlgo);
                          },
                    child: Text("RESET"))),
            Expanded(
                child: FlatButton(
                    onPressed: isSorting ? null : sort, child: Text("SORT"))),
            Expanded(
                child: FlatButton(
                    onPressed: isSorting ? null : changeSpeed,
                    child: Text(
                      "${speed + 1}x",
                      style: TextStyle(fontSize: 20),
                    ))),
          ],
        ),
      ),
    );
  }
}

class BarPainter extends CustomPainter {
  final double width;
  final int value;
  final int index;

  BarPainter({this.width, this.value, this.index});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Color(0xFF1D9A6C);
    paint.strokeWidth = width;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(index * this.width, 598),
        Offset(index * this.width, 600 - this.value.ceilToDouble()), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Platform extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(0, 600);
    final p2 = Offset(width, 600);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
