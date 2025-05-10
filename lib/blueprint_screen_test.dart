import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'dart:developer';
import 'package:flutter_html/flutter_html.dart';
import 'package:file_picker/file_picker.dart';

class BluePrintScreenTest extends StatefulWidget {
  const BluePrintScreenTest({super.key});

  @override
  State<BluePrintScreenTest> createState() => _BluePrintScreenTestState();
}

class _BluePrintScreenTestState extends State<BluePrintScreenTest> {
  ReceiptController? controller;
  File? selectedFile;
  String? selectedFilePath;
  bool isPDF = false;

  pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        selectedFile = file;
        selectedFilePath = file.path;
        isPDF = file.path.toLowerCase().endsWith('.pdf');
      });
    } else {
      log('No file selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Bluetooth Printer'),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            final address = await FlutterBluetoothPrinter.selectDevice(context);
            if (address != null) {
              await controller?.print(
                address: address.address,
                keepConnected: true,
                addFeeds: 4,
              );
            } else {
              log('Failed Printing!');
            }
          },
          child: Text(
            'Select Printer & Print',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: selectedFilePath != null
          ? (ElevatedButton(
              onPressed: pickAndUploadFile, // Upload PDF button
              child: Text('Upload File'),
            ))
          : Receipt(
              builder: (context) => SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Image.asset('assets/app_logo.jpeg'),
                    ],
                  ),
                ),
              ),
              onInitialized: (controller) {
                this.controller = controller;
              },
            ),
    );
  }
}
