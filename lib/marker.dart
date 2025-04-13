import 'package:flutter/material.dart';

class Marker {
  final Offset position;
  Offset currentPosition;
  final Icon icon;
  final double size;

  Marker({
    required this.position,
    required this.icon,
    this.size = 16,
  }): currentPosition = position;

  void recalculateCurrentPos(TransformationController transformController) {
    currentPosition = MatrixUtils.transformPoint(
      transformController.value,
      position
    );
  }

  Widget build(TransformationController transformController) {
    recalculateCurrentPos(transformController);

    return Positioned(
      left: currentPosition.dx - size / 2,  // Center the icon at the touch position
      top: currentPosition.dy - size / 2,
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