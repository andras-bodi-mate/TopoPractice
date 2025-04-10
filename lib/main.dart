import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:photo_view/photo_view.dart';


void main() => runApp(RibbonApp());

class RibbonApp extends StatelessWidget {
  const RibbonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Ribbon UI',
      theme: ThemeData(useMaterial3: true),
      home: RibbonHomePage(),
    );
  }
}

class RibbonHomePage extends StatefulWidget {
  const RibbonHomePage({super.key});

  @override
  State<RibbonHomePage> createState() => RibbonHomePageState();
}

class DraggableImageViewer extends StatefulWidget {
  const DraggableImageViewer({super.key});

  @override
  DraggableImageViewerState createState() => DraggableImageViewerState();
}

class DraggableImageViewerState extends State<DraggableImageViewer> {
  Offset offset = Offset.zero;
  bool middleButtonDown = false;
  Offset? lastMousePosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons == kMiddleMouseButton) {
          middleButtonDown = true;
          lastMousePosition = event.position;
        }
      },
      onPointerUp: (event) {
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons & kMiddleMouseButton == 0) {
          middleButtonDown = false;
          lastMousePosition = null;
        }
      },
      onPointerMove: (event) {
        if (middleButtonDown && lastMousePosition != null) {
          final delta = event.position - lastMousePosition!;
          setState(() {
            offset += delta;
          });
          lastMousePosition = event.position;
        }
      },
      child: Container(
        color: Colors.grey.shade100,
        child: Stack(
          children: [
            Transform.translate(
              offset: offset,
              child: Center(
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/9/99/SampleUserIcon.png',
                  width: 300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RibbonHomePageState extends State<RibbonHomePage>
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
      body: PhotoView(
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
