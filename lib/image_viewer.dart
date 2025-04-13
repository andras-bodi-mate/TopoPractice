import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  final ImageProvider imageProvider;
  final TransformationController? controller;

  const ImageViewer({
    super.key,
    required this.imageProvider,
    this.controller,
  });

  @override
  State<ImageViewer> createState() => ImageViewerState();
}

class ImageViewerState extends State<ImageViewer> {
  late final TransformationController myTransform;

  @override
  void initState() {
    super.initState();
    myTransform = widget.controller ?? TransformationController();
  }

  TransformationController get controller => myTransform;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: myTransform,
      panEnabled: true,
      scaleEnabled: true,
      maxScale: 15,
      constrained: false,
      child: Image(image: widget.imageProvider, fit: BoxFit.scaleDown),
    );
  }
}