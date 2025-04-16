import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class Tracker {
  final Offset position;
  final TransformationController transformationController;
  Offset currentPosition;

  Tracker({
    required this.position,
    required this.transformationController
  }): currentPosition = position;

  factory Tracker.fromTransformed(Offset transformedPosition, TransformationController transformationController) {
    Offset position = inverseTransformPoint(transformationController.value, transformedPosition);
    return Tracker(position: position, transformationController: transformationController);
  }

  void update() {
    currentPosition = MatrixUtils.transformPoint(
      transformationController.value,
      position
    );
  }

  Offset getPosition() {
    return currentPosition;
  }
  
  static Offset inverseTransformPoint(Matrix4 matrix, Offset screenPoint) {
    try {
      Matrix4 inverse = Matrix4.inverted(matrix);

      final Vector3 vector = Vector3(screenPoint.dx, screenPoint.dy, 0);
      final Vector3 transformed = inverse.transform3(vector);
      return Offset(transformed.x, transformed.y);

    } on ArgumentError {
      return screenPoint;
    }
  }
}