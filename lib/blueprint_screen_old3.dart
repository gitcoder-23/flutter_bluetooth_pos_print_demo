import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class BluePrintScreenOld3 extends StatefulWidget {
  const BluePrintScreenOld3({super.key});

  @override
  State<BluePrintScreenOld3> createState() => _BluePrintScreenOld3State();
}

class _BluePrintScreenOld3State extends State<BluePrintScreenOld3> {
  String? pdfPath; // Variable to store the path of the PDF

  // Method to pick and upload PDF file from device
  Future<void> _pickAndUploadFile() async {
    // Pick a file from device
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      // Get the path of the selected file
      String? selectedFilePath = result.files.single.path;

      if (selectedFilePath != null) {
        // Set the path for the picked PDF
        setState(() {
          pdfPath = selectedFilePath;
        });
      }
    } else {
      // Show a message if no file is selected
      setState(() {
        pdfPath = null;
      });
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickAndUploadFile, // Upload PDF button
              child: Text('Upload File'),
            ),
            SizedBox(height: 20),
            pdfPath == null
                ? Text('No file selected')
                : Container(
                    height: 500, // Set a fixed height for the PDF view
                    child: PDFView(
                      filePath: pdfPath, // Display the selected PDF
                    ),
                  ),
          ],
        ),
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
          onPressed: pdfPath != null
              ? () {
                  // Trigger the print function if a file is selected
                  print("Start printing...");
                }
              : null,
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
