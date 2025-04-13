import 'dart:io'; 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

//import 'package:file_picker/file_picker.dart';

import 'map.dart';

void main() async {
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManager.ensureInitialized();
      WindowManager.instance.setMinimumSize(const Size(600, 600));
    }
  }

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Topo Gyak',
      theme: ThemeData(useMaterial3: true),
      home: MainPage(),
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey.shade100,
            child:
            TabBar(
              controller: tabController,
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
              labelColor: Colors.black,
            )
          ),
          Container(
            width: double.infinity,
            color: Colors.blueGrey.shade50,
            child: buildRibbonContent(tabController.index),
          ),
          Expanded(
            child: Map(imageProvider: AssetImage('assets/images/europa.png'))
          )
        ]
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
