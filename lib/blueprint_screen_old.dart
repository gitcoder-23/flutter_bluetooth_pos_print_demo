import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'dart:developer';

class BluePrintScreenOld extends StatefulWidget {
  const BluePrintScreenOld({super.key});

  @override
  State<BluePrintScreenOld> createState() => _BluePrintScreenOldState();
}

class _BluePrintScreenOldState extends State<BluePrintScreenOld> {
  ReceiptController? controller;

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
      body: Receipt(
        builder: (context) => Column(children: [
          Text('Adddress', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('123 Sunshine Blvd'),
          Text('Los Angeles, CA 90001'),
          Text('United States'),
          SizedBox(height: 10),
          Text('Phone: (213) 555-1234'),
          Text('Email: info@example.com'),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('S1', style: TextStyle(fontSize: 15)),
              ),
              Expanded(
                flex: 3,
                child: Text('Product', style: TextStyle(fontSize: 15)),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Rate',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Total',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text('2', style: TextStyle(fontSize: 14)),
              ),
              Expanded(
                flex: 3,
                child: Text('Apple', style: TextStyle(fontSize: 14)),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '118',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '118',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'Total',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Expanded(
                child: Text(':'),
              ),
              Expanded(
                child: Text(
                  '310',
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ), // Row
        ]),
        onInitialized: (controller) {
          this.controller = controller;
        },
      ),
    );
  }
}
