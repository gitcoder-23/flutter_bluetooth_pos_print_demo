import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

import 'const/mock_data.dart';

class BluePrinterDesignBackup2 extends StatefulWidget {
  const BluePrinterDesignBackup2({super.key});

  @override
  State<BluePrinterDesignBackup2> createState() =>
      _BluePrinterDesignBackup2State();
}

class _BluePrinterDesignBackup2State extends State<BluePrinterDesignBackup2> {
  ReceiptController? controller;
  BluetoothDevice? _connectedDevice;
  bool _isConnecting = false;
  bool _isPrinting = false;
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      setState(() {
        _isConnecting = true;
      });

      final isConnected = await FlutterBluetoothPrinter.connect(
        device.address,
      );

      if (isConnected) {
        setState(() {
          _connectedDevice = device;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to ${device.name}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _printReceipt() async {
    if (_connectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to a printer first')),
      );
      return;
    }

    try {
      setState(() {
        _isPrinting = true;
      });
      controller?.paperSize = PaperSize.mm80;

      // Print the receipt
      await controller?.print(
        address: _connectedDevice!.address,
        keepConnected: true,
        addFeeds: 4,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print job sent to ${_connectedDevice!.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Printing failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  Future<void> _selectAndPrint() async {
    final device = await FlutterBluetoothPrinter.selectDevice(context);
    if (device != null) {
      await _connectToDevice(device);
      if (_connectedDevice != null) {
        await _printReceipt();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No printer selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text('Bluetooth Printer'),
          centerTitle: true,
          actions: [
            if (_connectedDevice != null)
              IconButton(
                icon:
                    const Icon(Icons.bluetooth_connected, color: Colors.white),
                onPressed: () async {
                  await FlutterBluetoothPrinter.disconnect(
                      _connectedDevice!.address);
                  setState(() {
                    _connectedDevice = null;
                  });
                },
              ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_connectedDevice != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Connected to: ${_connectedDevice!.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed:
                    _isConnecting || _isPrinting ? null : _selectAndPrint,
                child: _isConnecting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : _isPrinting
                        ? const Text('Printing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ))
                        : const Text(
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
        body: Receipt(
          defaultTextStyle: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
          containerBuilder: (context, child) {
            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: child,
              ),
            );
          },
          builder: (context) => buildContent(),
          onInitialized: (controller) {
            this.controller = controller;
          },
        ));
  }

  Widget buildContent() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          'assets/app_logo.jpeg',
          width: 140,
        ),
        // Header Section
        Text('INVOICE: ${posData[0]["invoice"]}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        SizedBox(height: 5),
        Text('Date: ${posData[0]["date"]}',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
        SizedBox(height: 5),
        Text('Customer: ${posData[0]["customer"]}',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
        Text('Sold By: ${posData[0]["sold_by"]}',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
        SizedBox(height: 5),

        // Items Table Header
        builderTableSingle(),
        buildTableBuilderAll(),
        SizedBox(height: 3),

        // Summary Section
        Align(
          alignment: Alignment.centerRight,
          child: Table(
            columnWidths: {1: FixedColumnWidth(100)},
            children: [
              TableRow(
                children: [
                  Text('Discount:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${posData[0]["discount"]}',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
                ],
              ),
              TableRow(
                children: [
                  Text('Shipping:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${posData[0]["shipping"]}',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
                ],
              ),
              TableRow(
                children: [
                  Text('Total:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${posData[0]["total"]}',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
                ],
              ),
              TableRow(
                children: [
                  Text('Paid:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${posData[0]["paid"]}',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
                ],
              ),
              TableRow(
                children: [
                  Text('Due:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${posData[0]["due"]}',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 2),

        // Payments Section
        Text('Payments:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 4),

        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                Padding(
                  padding: EdgeInsets.all(2),
                  child: Text('Txn No',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Padding(
                  padding: EdgeInsets.all(2),
                  child: Text('Mode',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Padding(
                  padding: EdgeInsets.all(2),
                  child: Text('Date',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Padding(
                  padding: EdgeInsets.all(2),
                  child: Text('Amount',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
            for (var payment in posData[0]["payments"])
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: Text(
                      payment["txn_no"],
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: Text(
                      payment["mode"],
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: Text(
                      payment["date"],
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: Text(
                      payment["amount"].toString(),
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget builderTableSingle() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: posData[0]["items"].length,
      itemBuilder: (context, index) {
        final item = posData[0]["items"][index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: ${item["name"]}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  2: FixedColumnWidth(60),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Qty',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Rate',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Tax',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Amount',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(item["qty"]),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(item["rate"].toStringAsFixed(2)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(item["tax"]),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(item["amount"].toStringAsFixed(2)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTableBuilderAll() {
    return Table(
      columnWidths: {
        1: FixedColumnWidth(60),
        3: FixedColumnWidth(50),
        4: FixedColumnWidth(80),
      },
      defaultColumnWidth: FlexColumnWidth(1),
      border: TableBorder.all(),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            Padding(
              padding: EdgeInsets.all(3),
              child: Text('Item',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: EdgeInsets.all(3),
              child: Text('Qty',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: EdgeInsets.all(3),
              child: Text('Rate',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: EdgeInsets.all(3),
              child: Text('Tax',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: EdgeInsets.all(3),
              child: Text('Amount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
        // Items Rows
        for (var item in posData[0]["items"])
          TableRow(
            children: [
              Padding(
                padding: EdgeInsets.all(3),
                child: Text(item["name"], style: TextStyle(fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.all(3),
                child: Text(item["qty"], style: TextStyle(fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.all(3),
                child: Text(item["rate"].toString(),
                    style: TextStyle(fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.all(3),
                child: Text(item["tax"], style: TextStyle(fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.all(3),
                child: Text(item["amount"].toString(),
                    style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
      ],
    );
  }
}
