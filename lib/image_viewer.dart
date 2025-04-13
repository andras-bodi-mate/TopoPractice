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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Size containerSize = renderBox.size;

        final double scaleX = containerSize.width / imageWidth;
        final double scaleY = containerSize.height / imageHeight;
        final double scale = scaleX < scaleY ? scaleX : scaleY;

        final double dx = (containerSize.width - imageWidth * scale) / 2;
        final double dy = (containerSize.height - imageHeight * scale) / 2;

        transformController.value = Matrix4.identity()
          ..translate(dx, dy)
          ..scale(scale);
      });
    }));
  }

  TransformationController get controller => transformController;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: transformController,
      panEnabled: true,
      scaleEnabled: true,
      minScale: 1.0,
      maxScale: 15,
      boundaryMargin: EdgeInsets.all(double.infinity),
      constrained: false,
      
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          child: Image(image: widget.imageProvider)
        )
      )
    );
  }
}