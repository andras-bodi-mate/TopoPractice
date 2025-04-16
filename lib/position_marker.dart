import 'package:flutter/material.dart';

import 'tracker.dart';

class PositionMarker {
  final Tracker tracker;
  final Icon icon;
  final double size;

  PositionMarker({
    required this.tracker,
    required this.icon,
    this.size = 16,
  });

  void updatePos() {
    tracker.update();
  }

  Widget build() {
    tracker.update();

    return Positioned(
      left: tracker.getPosition().dx - size / 2,  // Center the icon at the touch position
      top: tracker.getPosition().dy - size / 2,
      child: IgnorePointer(
        ignoring: true,
        child: SizedBox(
          width: size,
          height: size,
          child: icon,
        )
      )
    );
  }
}