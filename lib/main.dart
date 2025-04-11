import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:photo_view/photo_view.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    WindowManager.instance.setMinimumSize(const Size(600, 600));
  }
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Ribbon UI',
      theme: ThemeData(useMaterial3: true),
      home: MainPage(),
    );
  }
}

class UniversalPhotoView extends StatefulWidget {
  final ImageProvider imageProvider;

  const UniversalPhotoView({super.key, required this.imageProvider});

  @override
  State<UniversalPhotoView> createState() => UniversalPhotoViewState();
}

class UniversalPhotoViewState extends State<UniversalPhotoView> {
  final PhotoViewController controller = PhotoViewController();
  final PhotoViewScaleStateController scaleStateController = PhotoViewScaleStateController();

  bool isDragging = false;
  Offset? lastPosition;
  double currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    controller.outputStateStream.listen((state) {
      currentScale = state.scale ?? 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse &&
            (event.buttons == kMiddleMouseButton || event.buttons == kSecondaryMouseButton)) {
          isDragging = true;
          lastPosition = event.position;
        }
      },
      onPointerUp: (event) {
        if (event.kind == PointerDeviceKind.mouse) {
          isDragging = false;
          lastPosition = null;
        }
      },
      onPointerMove: (event) {
        if (isDragging && lastPosition != null) {
          final delta = event.position - lastPosition!;
          controller.updateMultiple(
            position: controller.position - delta,
          );
          lastPosition = event.position;
        }
      },
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          final zoomAmount = -event.scrollDelta.dy * 0.0015;
          final newScale = (currentScale * (1 + zoomAmount)).clamp(0.5, 5.0);

          // Optional: Zoom toward mouse pointer
          final renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(event.position);

          controller.scale = newScale;
          controller.position += (localPosition - controller.position) * zoomAmount;
          print(zoomAmount);
        }
      },
      child: PhotoView(
        imageProvider: widget.imageProvider,
        controller: controller,
        scaleStateController: scaleStateController,
        backgroundDecoration: BoxDecoration(color: Colors.white),
        enablePanAlways: true,
        tightMode: false,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 5.0,
      ),
    );
  }
}


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final List<String> tabs = ['Home', 'Insert', 'View'];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      setState(() {}); // So we can show the correct ribbon content
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.blueGrey.shade100,
              child: TabBar(
                controller: tabController,
                tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                labelColor: Colors.black,
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.blueGrey.shade50,
              child: buildRibbonContent(tabController.index),
            ),
          ],
        ),
      ),
      body: UniversalPhotoView(
        imageProvider: AssetImage('assets/images/europa.png'),
      )
    );
  }

  Widget buildRibbonContent(int index) {
    switch (index) {
      case 0:
        return buildHomeTab();
      case 1:
        return buildInsertTab();
      case 2:
        return buildViewTab();
      default:
        return SizedBox.shrink();
    }
  }

  Widget buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          commandGroup("Clipboard", [
            IconButton(onPressed: () {}, icon: Icon(Icons.paste)),
            IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
            IconButton(onPressed: () {}, icon: Icon(Icons.cut)),
          ]),
          commandGroup("Font", [
            IconButton(onPressed: () {}, icon: Icon(Icons.format_bold)),
            IconButton(onPressed: () {}, icon: Icon(Icons.format_italic)),
          ]),
        ],
      ),
    );
  }

  Widget buildInsertTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 16,
        children: [
          commandGroup("Shapes", [
            IconButton(onPressed: () {}, icon: Icon(Icons.circle)),
            IconButton(onPressed: () {}, icon: Icon(Icons.rectangle)),
          ]),
          commandGroup("Images", [
            IconButton(onPressed: () {}, icon: Icon(Icons.image)),
          ]),
        ],
      ),
    );
  }

  Widget buildViewTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 16,
        children: [
          commandGroup("Zoom", [
            IconButton(onPressed: () {}, icon: Icon(Icons.zoom_in)),
            IconButton(onPressed: () {}, icon: Icon(Icons.zoom_out)),
          ]),
          commandGroup("Layout", [
            IconButton(onPressed: () {}, icon: Icon(Icons.view_agenda)),
          ]),
        ],
      ),
    );
  }

  Widget commandGroup(String label, List<Widget> buttons) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: buttons),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
