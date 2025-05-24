import 'package:bluetooth_printer/blueprint_screen_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';

import 'blue_printer_design.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'blue_printer_design_backup.dart';
import 'blueprint_new_test/blueprint_demo1.dart';
import 'blueprint_new_test/blueprint_demo3.dart';
import 'blueprint_new_test/bluetooth_demo2.dart';
import 'blueprint_screen_old.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      // home: BlueprintDemo2(),
      // home: BlueprintDemo1(),
      // home: BlueprintDemo3(),
      home: BluePrintScreenOld(),
      // home: BluePrinterDesignBackup(),
    );
  }
}
