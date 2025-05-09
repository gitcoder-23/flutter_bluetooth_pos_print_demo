import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class BluePrintScreenOld4 extends StatefulWidget {
  const BluePrintScreenOld4({super.key});

  @override
  State<BluePrintScreenOld4> createState() => _BluePrintScreenOld4State();
}

class _BluePrintScreenOld4State extends State<BluePrintScreenOld4> {
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

  // Method to remove the selected PDF
  void _removePdf() {
    setState(() {
      pdfPath = null; // Reset pdfPath to null to remove the PDF
    });
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
            // Show the upload button only when no PDF is uploaded
            pdfPath == null
                ? ElevatedButton(
                    onPressed: _pickAndUploadFile, // Upload PDF button
                    child: Text('Upload File'),
                  )
                : Container(),
            SizedBox(height: 20),
            // If PDF is uploaded, show the PDF and the cross icon
            pdfPath != null
                ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      // Display PDF
                      Container(
                        height: 500, // Set a fixed height for the PDF view
                        child: PDFView(
                          filePath: pdfPath, // Display the selected PDF
                        ),
                      ),
                      // Close icon to remove the PDF
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: _removePdf, // Remove the PDF when clicked
                      ),
                    ],
                  )
                : Text('No file selected'),
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
