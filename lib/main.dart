import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final availableColours = [
    Colors.black,
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
  ];

  int selectedColour = 0;

  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];

  DrawingPoint? currentDrawingPoint;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SketchPad',
      home: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  currentDrawingPoint = DrawingPoint(
                    id: DateTime.now().microsecondsSinceEpoch,
                    offsets: [
                      details.localPosition,
                    ],
                    color: availableColours[selectedColour],
                  );

                  if (currentDrawingPoint == null) return;

                  drawingPoints.add(currentDrawingPoint!);
                  historyDrawingPoints = List.of(drawingPoints);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  if (currentDrawingPoint == null) return;

                  currentDrawingPoint = currentDrawingPoint?.copyWith(
                    offsets: currentDrawingPoint!.offsets
                      ..add(details.localPosition),
                  );

                  drawingPoints.last = currentDrawingPoint!;
                  historyDrawingPoints = List.of(drawingPoints);
                });
              },
              onPanEnd: (_) {
                setState(() {
                  currentDrawingPoint = null;
                });
              },
              child: CustomPaint(
                painter: DrawingPainter(drawingPoints: drawingPoints),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableColours.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 10,
                    );
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColour = index;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: availableColours[index],
                            border: index == selectedColour
                                ? Border.all(
                                    color: availableColours[index]
                                                .computeLuminance() >
                                            0.18
                                        ? Colors.black
                                        : Colors.white60,
                                    width: 2)
                                : null,
                            shape: BoxShape.circle),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              elevation: 0,
              heroTag: "Delete",
              backgroundColor: historyDrawingPoints.isEmpty
                  ? const Color.fromARGB(49, 126, 126, 126)
                  : Colors.red[500],
              onPressed: historyDrawingPoints.isEmpty
                  ? null
                  : () {
                      setState(() {
                        drawingPoints.clear();
                        historyDrawingPoints.clear();
                      });
                    },
              child: Icon(
                Icons.delete,
                color:
                    historyDrawingPoints.isEmpty ? Colors.grey : Colors.white,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              elevation: 0,
              heroTag: "Undo",
              backgroundColor: drawingPoints.isEmpty
                  ? const Color.fromARGB(49, 126, 126, 126)
                  : Colors.blue[300],
              onPressed: drawingPoints.isEmpty
                  ? null
                  : () {
                      setState(() {
                        drawingPoints.removeLast();
                      });
                    },
              child: Icon(Icons.undo,color: drawingPoints.isEmpty ? Colors.grey : Colors.white,),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              elevation: 0,
              heroTag: "Redo",
              backgroundColor:
                  historyDrawingPoints.length == drawingPoints.length
                      ? const Color.fromARGB(49, 126, 126, 126)
                      : Colors.blue[300],
              onPressed: historyDrawingPoints.length == drawingPoints.length
                  ? null
                  : () {
                      setState(() {
                        drawingPoints
                            .add(historyDrawingPoints[drawingPoints.length]);
                      });
                    },
              child: Icon(Icons.redo, color: historyDrawingPoints.length == drawingPoints.length
                  ? Colors.grey: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingPoint {
  int id;
  List<Offset> offsets;
  Color color;

  DrawingPoint({
    this.id = -1,
    this.offsets = const [],
    this.color = Colors.black,
  });

  DrawingPoint copyWith({List<Offset>? offsets}) {
    return DrawingPoint(
      id: id,
      color: color,
      offsets: offsets ?? this.offsets,
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({required this.drawingPoints});

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingPoint in drawingPoints) {
      final paint = Paint()
        ..isAntiAlias = true
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round
        ..color = drawingPoint.color;

      for (var i = 0; i < drawingPoint.offsets.length; i++) {
        if (i != drawingPoint.offsets.length - 1) {
          canvas.drawLine(
              drawingPoint.offsets[i], drawingPoint.offsets[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
