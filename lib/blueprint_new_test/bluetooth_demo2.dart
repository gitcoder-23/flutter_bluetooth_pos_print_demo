import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class BlueprintDemo2 extends StatefulWidget {
  const BlueprintDemo2({super.key});

  @override
  State<BlueprintDemo2> createState() => _BlueprintDemo2State();
}

class _BlueprintDemo2State extends State<BlueprintDemo2> {
  final _printer = FlutterThermalPrinter.instance;
  List<Printer> printers = [];
  bool isScanning = false;
  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  @override
  void dispose() {
    _devicesStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    _devicesStreamSubscription?.cancel();
    await _printer
        .getPrinters(connectionTypes: [ConnectionType.USB, ConnectionType.BLE]);
    _devicesStreamSubscription = _printer.devicesStream.listen((event) {
      setState(() {
        printers =
            event.where((p) => p.name != null && p.name!.isNotEmpty).toList();
      });
    });
  }

  // Future<void> _printWithPrinter(Printer printer) async {
  //   await _printer.connect(printer);
  //   await _printer.printWidget(
  //     context,
  //     printer: printer,
  //     printOnBle: true,
  //     widget: _receiptWidget(),
  //   );
  //   await _printer.disconnect(printer);
  // }

  Future<void> _printWithPrinter(Printer printer) async {
    try {
      await _printer.connect(printer);

      // Debug log
      debugPrint("Connected to printer: ${printer.name}");

      // Wait for UI frame rendering
      await Future.delayed(const Duration(milliseconds: 500));

      await _printer.printWidget(
        context,
        printer: printer,
        printOnBle: true,
        widget: _receiptWidget(),
      );

      // Add delay before disconnecting
      await Future.delayed(const Duration(seconds: 1));

      await _printer.disconnect(printer);

      debugPrint("Disconnected from printer.");
    } catch (e) {
      debugPrint("Print failed: $e");
    }
  }

  void _showPrinterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        _startScan();
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  const Center(
                    child: Text(
                      'Select a Printer',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (printers.isEmpty)
                    const Center(child: Text('Searching printers...')),
                  ...printers.map((printer) {
                    return ListTile(
                      title: Text(printer.name ?? 'Unknown'),
                      subtitle: Text(printer.connectionTypeString),
                      onTap: () async {
                        Navigator.pop(context);
                        await _printWithPrinter(printer);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _receiptWidget() {
    return RepaintBoundary(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        width: 550,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Adddress',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const Text(
                '123 Sunshine Blvd\nLos Angeles, CA 90001\nUnited States',
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Phone: (213) 555-1234\nEmail: info@example.com',
                textAlign: TextAlign.center),
            const Divider(thickness: 2),
            _buildRow('S1', 'Product', 'Rate', 'Total', isHeader: true),
            const Divider(thickness: 1),
            _buildRow('2', 'Apple', '118', '118'),
            _buildRow('2', 'Apple', '118', '118'),
            const Divider(thickness: 2),
            _buildRow('', '', 'Total:', '310', isTotal: true),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String col1, String col2, String col3, String col4,
      {bool isHeader = false, bool isTotal = false}) {
    TextStyle style = TextStyle(
      fontSize: 16,
      fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(col1, style: style)),
          Expanded(flex: 2, child: Text(col2, style: style)),
          Expanded(child: Text(col3, style: style, textAlign: TextAlign.right)),
          Expanded(child: Text(col4, style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade700,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Bluetooth Printer'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: _receiptWidget()),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _showPrinterBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Center(
                child: Text(
                  "Select Printer & Print",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
