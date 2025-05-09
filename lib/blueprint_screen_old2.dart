import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer';

class BluePrintScreenOld2 extends StatefulWidget {
  const BluePrintScreenOld2({super.key});

  @override
  State<BluePrintScreenOld2> createState() => _BluePrintScreenOld2State();
}

class _BluePrintScreenOld2State extends State<BluePrintScreenOld2> {
  ReceiptController? controller;
  String? pdfPath; // Variable to store the path of the PDF

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  // Method to load PDF from assets
  Future<void> _loadPDF() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/download_qr.pdf');

    // Check if the file exists
    if (await file.exists()) {
      setState(() {
        pdfPath = file.path;
      });
    } else {
      // Copy PDF from assets to the app's document directory
      final byteData = await rootBundle.load('assets/download_qr.pdf');
      final buffer = byteData.buffer.asUint8List();
      await file.writeAsBytes(buffer);

      setState(() {
        pdfPath = file.path;
      });
    }
  }

  // Method to print the PDF
  Future<void> _printPDF() async {
    final address = await FlutterBluetoothPrinter.selectDevice(context);
    if (address != null && pdfPath != null) {
      await controller?.print(
        address: address.address,
        keepConnected: true,
        addFeeds: 4,
      );
      log('Printing started!');
    } else {
      log('Failed Printing!');
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
      body: pdfPath == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: pdfPath, // Display the PDF
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
          onPressed: _printPDF, // Trigger the print function
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
    );
  }
}
