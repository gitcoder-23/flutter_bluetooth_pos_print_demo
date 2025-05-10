import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';

import 'blueprint_screen.dart';
import 'blueprint_screen_new.dart';
import 'blueprint_screen_old.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ReceiptController? controller;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluetooth Printer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BluePrintScreenNew(),
    );
  }
}
