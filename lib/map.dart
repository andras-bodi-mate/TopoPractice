import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'marker.dart';
import 'image_viewer.dart';

class Map extends StatefulWidget {
  final ImageProvider imageProvider;

  const Map({
    super.key,
    required this.imageProvider,
  });

  @override
  State<Map> createState() => MapState();
}

class MapState extends State<Map> {
  final TransformationController transformController = TransformationController();
  final List<Marker> markers = [];

  late final Ticker ticker;
  Matrix4 lastTransform = Matrix4.identity();

  @override
  void initState() {
    super.initState();

    lastTransform = transformController.value.clone();

    ticker = Ticker((Duration _) {
      final currentMatrix = transformController.value;
      if (!matrixEquals(currentMatrix, lastTransform)) {
        lastTransform = currentMatrix.clone();
        updateAllMarkerPositions();
        setState(() {}); // causes rebuild
      }
    });

    ticker.start();
  }

  bool matrixEquals(Matrix4 a, Matrix4 b) {
    for (int i = 0; i < 16; i++) {
      if ((a.storage[i] - b.storage[i]).abs() > 0.001) return false;
    }
    return true;
  }

  Offset inverseTransformPoint(Matrix4 matrix, Offset screenPoint) {
    try {
      Matrix4 inverse = Matrix4.inverted(matrix);

      final Vector3 vector = Vector3(screenPoint.dx, screenPoint.dy, 0);
      final Vector3 transformed = inverse.transform3(vector);
      return Offset(transformed.x, transformed.y);

    } on ArgumentError {
      return screenPoint;
    }
  }

  void addMarker(Offset position) {
    final marker = Marker(
      position: inverseTransformPoint(transformController.value, position),
      icon: Icon(Icons.close, color: Colors.red, size: 16), // Use the icon here
      size: 16,
    );
    setState(() {
      markers.add(marker);
    });
  }

  void updateAllMarkerPositions() {
    for (final marker in markers) {
      marker.recalculateCurrentPos(transformController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => addMarker(event.localPosition),
      child: Stack(
        children: [
          Positioned.fill(
            child: ImageViewer(
              imageProvider: widget.imageProvider,
              controller: transformController,
            ),
          ),
          ...markers.map((marker) => marker.build(transformController)),
        ],
      )
    );
  }
}
