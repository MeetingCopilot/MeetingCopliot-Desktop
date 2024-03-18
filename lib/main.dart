import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meeting_copilot_desktop/page/home_page.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
  appWindow.size = const Size(1000, 700);
  debugPaintSizeEnabled = true;
  runApp(const MyApp());
  appWindow.show();
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1000, 700);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Custom window with Flutter";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}
