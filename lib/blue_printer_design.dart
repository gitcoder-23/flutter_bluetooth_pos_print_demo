import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class BluePrinterDesign extends StatefulWidget {
  const BluePrinterDesign({super.key});

  @override
  State<BluePrinterDesign> createState() => _BluePrinterDesignState();
}

class _BluePrinterDesignState extends State<BluePrinterDesign> {
  ReceiptController? controller;
  File? selectedFile;
  String? selectedFilePath;
  bool isPDF = false;

  pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'png',
        'jpeg',
        'pdf',
      ],
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.only(bottom: 20),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    selectedFile = null;
                    selectedFilePath = null;
                    isPDF = false;
                  });
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final address =
                      await FlutterBluetoothPrinter.selectDevice(context);
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
            ],
          ),
        ),
      ),
      body: selectedFilePath == null
          ? Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'No file selected',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickAndUploadFile, // Upload PDF button
                    child: Text('Upload File',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            )
          : Receipt(
              builder: (context) => Container(
                width: double.infinity,
                child: Column(
                  children: [
                    if (selectedFilePath != null)
                      isPDF
                          ? SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SizedBox(
                                height: 500,
                                width: 500,
                                child: PDFView(
                                  filePath: selectedFilePath,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Image.file(
                                File(selectedFilePath!),
                                width: 400,
                                height: 400,
                                fit: BoxFit.contain,
                              ),
                            )
                  ],
                ),
              ),
              onInitialized: (controller) {
                this.controller = controller;
              },
            ),
    );
  }
}
