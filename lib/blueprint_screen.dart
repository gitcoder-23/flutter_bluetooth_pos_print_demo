import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

class BluePrintScreen extends StatefulWidget {
  const BluePrintScreen({super.key});

  @override
  State<BluePrintScreen> createState() => _BluePrintScreenState();
}

class _BluePrintScreenState extends State<BluePrintScreen> {
  String? pdfPath; // Variable to store the path of the PDF
  ReceiptController? controller;
  final FlutterBluetoothPrinter printer =
      FlutterBluetoothPrinter(); // Initialize Bluetooth printer

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

  // Method to convert PDF to Image
  Future<Map<String, dynamic>> _convertPdfToImage(String path) async {
    // In this example, we just create a simple image as a placeholder.
    img.Image image = img.Image(
        width: 200, height: 200); // Create a blank image (just for example)
    // You will need to implement actual PDF to image conversion here

    // Convert image to Uint8List
    Uint8List imageBytes = Uint8List.fromList(img.encodeJpg(image));

    return {
      'imageBytes': imageBytes,
      'imageWidth': image.width,
      'imageHeight': image.height,
    };
  }

  // Method to print the PDF as an image
  Future<void> _printPDF() async {
    if (pdfPath != null) {
      // Convert the PDF to an image
      Map<String, dynamic> imageData = await _convertPdfToImage(pdfPath!);

      // Get imageBytes, imageWidth, and imageHeight from the conversion
      Uint8List imageBytes = imageData['imageBytes'];
      int imageWidth = imageData['imageWidth'];
      int imageHeight = imageData['imageHeight'];

      // Select Bluetooth printer
      final device = await FlutterBluetoothPrinter.selectDevice(context);
      if (device != null) {
        // Send the image to the printer
        await FlutterBluetoothPrinter.connect(device.address);

        // Print the image using the FlutterBluetoothPrinter package
        await FlutterBluetoothPrinter.printImageSingle(
          address: device.address,
          imageBytes: imageBytes,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          keepConnected: true,
          paperSize: PaperSize.mm58, // Default paper size
        );

        print("Printing PDF...");

        await FlutterBluetoothPrinter.disconnect(
            device.address); // Disconnect after printing
      } else {
        print("No printer selected!");
      }
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.only(bottom: 25),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: pdfPath != null ? _printPDF : null,
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
