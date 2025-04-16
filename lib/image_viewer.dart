import 'package:flutter/gestures.dart';
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
  late final TransformationController transformController;
  late double imageWidth, imageHeight;

  @override
  void initState() {
    super.initState();
    transformController = widget.controller ?? TransformationController();

    final stream = widget.imageProvider.resolve(const ImageConfiguration());
    stream.addListener(ImageStreamListener((info, _) {
      setState(() {
        imageWidth = info.image.width.toDouble();
        imageHeight = info.image.height.toDouble();
      });
    }));
  }

  TransformationController get controller => transformController;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerPanZoomUpdate: (event) {
        print(event);
      },

      child: InteractiveViewer(
        transformationController: transformController,
        panEnabled: true,
        scaleEnabled: true,
        minScale: 1.0,
        maxScale: 15,
        boundaryMargin: EdgeInsets.all(double.infinity),
        scaleFactor: kDefaultMouseScrollToScaleFactor,
        //constrained: false,
        child: SizedBox(
          child: Image(image: widget.imageProvider, fit: BoxFit.contain, alignment: Alignment.center,)
        )
      )
    );
  }
}