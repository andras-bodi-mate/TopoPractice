import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'position_marker.dart';
import 'outline_marker.dart';
import 'tracker.dart';
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
  final List<PositionMarker> positionMarkers = [];
  final List<OutlineMarker> outlineMarkers = [];

  late final Ticker ticker;

  @override
  void initState() {
    super.initState();

    ticker = Ticker((Duration _) {
      updateAllMarkerPositions();
      setState(() {}); // causes rebuild
    });

    ticker.start();
  }

  void addPositionMarker(Offset position) {
    final marker = PositionMarker(
      tracker: Tracker.fromTransformed(position, transformController),
      icon: Icon(Icons.close, color: Colors.red, size: 16), // Use the icon here
      size: 16,
    );
    setState(() {
      positionMarkers.add(marker);
    });
  }

  void addOutlineMarker(Offset position) {
    final marker = OutlineMarker(
      trackers: []
    );
    setState(() {
      outlineMarkers.add(marker);
    });
  }

  void updateAllMarkerPositions() {
    for (final marker in positionMarkers) {
      marker.updatePos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => addPositionMarker(event.localPosition),
      child: Stack(
        children: [
          Positioned.fill(
            child: ImageViewer(
              imageProvider: widget.imageProvider,
              controller: transformController,
            ),
          ),
          ...positionMarkers.map((marker) => marker.build()),
        ],
      )
    );
  }
}
