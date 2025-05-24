import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class BlueprintDemoOld1 extends StatefulWidget {
  const BlueprintDemoOld1({super.key});

  @override
  State<BlueprintDemoOld1> createState() => _BlueprintDemoOld1State();
}

class _BlueprintDemoOld1State extends State<BlueprintDemoOld1> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  String _ip = '192.168.0.100';
  String _port = '9100';

  List<Printer> printers = [];
  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startScan();
    });
  }

  void startScan() async {
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.getPrinters(connectionTypes: [
      ConnectionType.USB,
      ConnectionType.BLE,
    ]);
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) {
      log(event.map((e) => e.name).toList().toString());
      setState(() {
        printers = event;
        printers.removeWhere(
            (element) => element.name == null || element.name == '');
      });
    });
  }

  void stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
  }

  Future<List<int>> _generateReceipt() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    bytes += generator.text(
      "Test Network Print",
      styles: const PosStyles(
        bold: true,
        height: PosTextSize.size3,
        width: PosTextSize.size3,
      ),
    );
    bytes += generator.cut();
    return bytes;
  }

  Widget receiptWidget(String printerType) {
    return SizedBox(
      width: 550,
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'FLUTTER THERMAL PRINTER',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              _buildReceiptRow('Item', 'Price'),
              const Divider(),
              _buildReceiptRow('Apple', '\$1.00'),
              _buildReceiptRow('Banana', '\$0.50'),
              _buildReceiptRow('Orange', '\$0.75'),
              const Divider(thickness: 2),
              _buildReceiptRow('Total', '\$2.25', isBold: true),
              const SizedBox(height: 20),
              _buildReceiptRow('Printer Type', printerType),
              const SizedBox(height: 50),
              const Center(
                child: Text(
                  'Thank you for your purchase!',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String left, String right, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(right,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Printer Demo'),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('NETWORK',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _ip,
              decoration: const InputDecoration(labelText: 'Enter IP Address'),
              onChanged: (value) => _ip = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _port,
              decoration: const InputDecoration(labelText: 'Enter Port'),
              onChanged: (value) => _port = value,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final service = FlutterThermalPrinterNetwork(_ip,
                          port: int.parse(_port));
                      await service.connect();
                      final profile = await CapabilityProfile.load();
                      final generator = Generator(PaperSize.mm80, profile);
                      List<int> bytes =
                          await FlutterThermalPrinter.instance.screenShotWidget(
                        context,
                        generator: generator,
                        widget: receiptWidget("Network"),
                      );
                      bytes += generator.cut();
                      await service.printTicket(bytes);
                      await service.disconnect();
                    },
                    child: const Text('Print Widget to Network'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final service = FlutterThermalPrinterNetwork(_ip,
                          port: int.parse(_port));
                      await service.connect();
                      final bytes = await _generateReceipt();
                      await service.printTicket(bytes);
                      await service.disconnect();
                    },
                    child: const Text('Print Raw to Network'),
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            const Text('USB / BLE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: startScan,
                    child: const Text('Start Scan'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: stopScan,
                    child: const Text('Stop Scan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: printers.length,
                itemBuilder: (context, index) {
                  final printer = printers[index];
                  return ListTile(
                    title: Text(printer.name ?? 'No Name'),
                    subtitle: Text('Connected: ${printer.isConnected}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.print),
                      onPressed: () async {
                        await _flutterThermalPrinterPlugin.printWidget(
                          context,
                          printer: printer,
                          printOnBle: true,
                          widget: receiptWidget(printer.connectionTypeString),
                        );
                      },
                    ),
                    onTap: () async {
                      if (printer.isConnected ?? false) {
                        await _flutterThermalPrinterPlugin.disconnect(printer);
                      } else {
                        await _flutterThermalPrinterPlugin.connect(printer);
                      }
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
