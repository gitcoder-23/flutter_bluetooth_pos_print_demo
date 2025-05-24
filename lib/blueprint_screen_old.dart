import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'dart:async';
import 'dart:developer';

class BluePrintScreenOld extends StatefulWidget {
  const BluePrintScreenOld({super.key});

  @override
  State<BluePrintScreenOld> createState() => _BluePrintScreenOldState();
}

class _BluePrintScreenOldState extends State<BluePrintScreenOld> {
  ReceiptController? controller;
  BluetoothDevice? _connectedDevice;
  bool _isConnecting = false;
  bool _isPrinting = false;
  // Removed unused or incorrect BluetoothConnectState subscription.

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
              icon: const Icon(Icons.bluetooth_connected, color: Colors.white),
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
              onPressed: _isConnecting || _isPrinting ? null : _selectAndPrint,
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
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with full width
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.grey.shade300),
                ),
              ),
              child: const Text(
                'SUNSHINE STORE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Address section - full width
            const Text(
              '123 Sunshine Blvd\nLos Angeles, CA 90001\nUnited States',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),

            // Contact info - full width
            const Text(
              'Phone: (213) 555-1234 | Email: info@example.com',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 15),

            // Order info - full width
            Text(
              'Order #12345 | Date: ${DateTime.now().toString().substring(0, 10)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 15),

            // Items header - full width table
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1, color: Colors.grey.shade300),
                  bottom: BorderSide(width: 1, color: Colors.grey.shade300),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('Qty',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text('Description',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Price',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // Items list
            _buildItemRow('2', 'Fresh Apples', '118', '236'),
            _buildItemRow('1', 'Organic Bananas', '75', '75'),
            _buildItemRow('3', 'Orange Juice', '65', '195'),

            // Divider
            const Divider(thickness: 1),

            // Totals - full width
            _buildTotalRow('Subtotal:', '506'),
            _buildTotalRow('Tax (10%):', '50.60'),
            _buildTotalRow('Discount:', '-20.00'),
            _buildTotalRow('TOTAL:', '536.60', isBold: true),

            const SizedBox(height: 20),

            // Footer - full width
            const Text(
              'Thank you for your purchase!',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 5),
            const Text(
              'Please visit us again',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        onInitialized: (controller) {
          this.controller = controller;
        },
      ),
    );
  }

  Widget _buildItemRow(String qty, String desc, String price, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(qty),
          ),
          Expanded(
            flex: 4,
            child: Text(desc),
          ),
          Expanded(
            flex: 2,
            child: Text(
              price,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              total,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style:
                  isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(':'),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
            ),
          ),
        ],
      ),
    );
  }
}
