import 'package:flutter/material.dart';

import 'tracker.dart';

class OutlineMarker {
  List<Tracker> trackers;

  OutlineMarker({required this.trackers});

  void updatePosition() {
    for (final tracker in trackers) {
      tracker.update();
    }
  }

  void extend(Tracker newTracker) {
    trackers.add(newTracker);
  }
}