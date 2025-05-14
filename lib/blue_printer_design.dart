// import 'dart:developer';
// import 'dart:typed_data';

// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:image/image.dart' as img;

// class BluePrinterDesign extends StatefulWidget {
//   const BluePrinterDesign({super.key});

//   @override
//   State<BluePrinterDesign> createState() => _BluePrinterDesignState();
// }

// class _BluePrinterDesignState extends State<BluePrinterDesign> {
//   List<dynamic> pairedDevices = [];

//   List<dynamic> posData = [
//     {
//       "invoice": "SALE-348",
//       "date": "07-05-2025",
//       "customer": "ANISHA KHATUN",
//       "sold_by": "@SOUJANYA_360DEGREE",
//       "items": [
//         {
//           "name": "COFFEE MUG #1213",
//           "qty": "1piece",
//           "rate": 1.00,
//           "tax": "0%",
//           "amount": 1.00
//         },
//         {
//           "name": "OPPO F29 PRO 5G 8GB/256GB G.BLACK #IMEI-866658078758057",
//           "qty": "1piece",
//           "rate": 25422.88,
//           "tax": "18%",
//           "amount": 29999.00
//         },
//       ],
//       "discount": 2300.00,
//       "shipping": 0.00,
//       "total": 27700.00,
//       "paid": 27700.00,
//       "due": 0.00,
//       "payments": [
//         {
//           "txn_no": "PAY-IN-279",
//           "mode": "UPI",
//           "date": "07-05-2025",
//           "amount": 1700.00
//         },
//         {
//           "txn_no": "PAY-IN-278",
//           "mode": "Cash",
//           "date": "07-05-2025",
//           "amount": 26000.00
//         }
//       ]
//     }
//   ];

//   @override
//   void initState() {
//     super.initState();
//     getBluetoothDevices();
//   }

//   Future<void> getBluetoothDevices() async {
//     final paired = await PrintBluetoothThermal.pairedBluetooths;
//     setState(() {
//       pairedDevices = paired;
//     });
//   }

//   Future<void> startPrinting(String mac) async {
//     bool isConnected =
//         await PrintBluetoothThermal.connect(macPrinterAddress: mac);
//     log("Connected: $isConnected");

//     if (!isConnected) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to connect to printer')),
//       );
//       return;
//     }

//     CapabilityProfile profile = await CapabilityProfile.load();
//     final Generator generator = Generator(PaperSize.mm80, profile);
//     List<int> bytes = [];

//     // Optional Logo (if needed)
//     try {
//       final ByteData data = await rootBundle.load("assets/app_logo.jpeg");
//       final Uint8List imgBytes = data.buffer.asUint8List();
//       final img.Image? image = img.decodeImage(imgBytes);
//       if (image != null) {
//         bytes += generator.image(image);
//         bytes += generator.feed(1);
//       }
//     } catch (e) {
//       log("Image load failed: $e");
//     }

//     bytes += generator.text('INVOICE: ${posData[0]["invoice"]}',
//         styles: PosStyles(
//             align: PosAlign.left, bold: true, height: PosTextSize.size2));
//     bytes += generator.text('Date: ${posData[0]["date"]}');
//     bytes += generator.text('Customer: ${posData[0]["customer"]}');
//     bytes += generator.text('Sold By: ${posData[0]["sold_by"]}');
//     bytes += generator.feed(1);

//     // Items Header
//     bytes += generator.row([
//       PosColumn(text: 'Item', width: 6, styles: PosStyles(bold: true)),
//       PosColumn(text: 'Qty', width: 2, styles: PosStyles(bold: true)),
//       PosColumn(text: 'Rate', width: 2, styles: PosStyles(bold: true)),
//       PosColumn(text: 'Amt', width: 2, styles: PosStyles(bold: true)),
//     ]);

//     bytes += generator.hr();

//     for (var item in posData[0]["items"]) {
//       bytes += generator.row([
//         PosColumn(text: item["name"], width: 6),
//         PosColumn(text: item["qty"], width: 2),
//         PosColumn(text: item["rate"].toStringAsFixed(0), width: 2),
//         PosColumn(text: item["amount"].toStringAsFixed(0), width: 2),
//       ]);
//     }

//     bytes += generator.hr();

//     // Summary
//     bytes += generator.text("Discount: ${posData[0]["discount"]}");
//     bytes += generator.text("Shipping: ${posData[0]["shipping"]}");
//     bytes += generator.text("Total: ${posData[0]["total"]}",
//         styles: PosStyles(bold: true));
//     bytes += generator.text("Paid: ${posData[0]["paid"]}");
//     bytes += generator.text("Due: ${posData[0]["due"]}");
//     bytes += generator.feed(1);

//     // Payments
//     bytes += generator.text("Payments:", styles: PosStyles(bold: true));
//     for (var payment in posData[0]["payments"]) {
//       bytes += generator.text(
//           '${payment["txn_no"]} | ${payment["mode"]} | ${payment["date"]} | ₹${payment["amount"]}');
//     }

//     bytes += generator.feed(3);
//     bytes += generator.cut();

//     final result = await PrintBluetoothThermal.writeBytes(bytes);
//     log("Print result: $result");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bluetooth POS Printer'),
//         backgroundColor: Colors.redAccent,
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text("Paired Devices"),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: pairedDevices.length,
//               itemBuilder: (context, index) {
//                 final device = pairedDevices[index];
//                 return ListTile(
//                   title: Text(device["name"]),
//                   subtitle: Text(device["macAddress"]),
//                   trailing: ElevatedButton(
//                     child: const Text("Print"),
//                     onPressed: () async {
//                       await startPrinting(device["macAddress"]);
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

class BluePrinterDesign extends StatefulWidget {
  const BluePrinterDesign({super.key});

  @override
  State<BluePrinterDesign> createState() => _BluePrinterDesignState();
}

class _BluePrinterDesignState extends State<BluePrinterDesign> {
  List<dynamic> pairedDevices = [];
  List<dynamic> posData = [
    {
      "invoice": "SALE-348",
      "date": "07-05-2025",
      "customer": "ANISHA KHATUN",
      "sold_by": "@SOUJANYA_360DEGREE",
      "items": [
        {
          "name": "COFFEE MUG #1213",
          "qty": "1piece",
          "rate": 1.00,
          "tax": "0%",
          "amount": 1.00
        },
        {
          "name": "OPPO F29 PRO 5G 8GB/256GB G.BLACK #IMEI-866658078758057",
          "qty": "1piece",
          "rate": 25422.88,
          "tax": "18%",
          "amount": 29999.00
        },
        {
          "name": "VIVO F29 PRO 5G 8GB/256GB G.BLACK #IMEI-866658078758057",
          "qty": "1piece",
          "rate": 25322.88,
          "tax": "18%",
          "amount": 29099.00
        },
      ],
      "discount": 2300.00,
      "shipping": 0.00,
      "total": 27700.00,
      "paid": 27700.00,
      "due": 0.00,
      "payments": [
        {
          "txn_no": "PAY-IN-279",
          "mode": "UPI",
          "date": "07-05-2025",
          "amount": 1700.00
        },
        {
          "txn_no": "PAY-IN-278",
          "mode": "Cash",
          "date": "07-05-2025",
          "amount": 26000.00
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    getBluetoothDevices();
  }

  Future<void> getBluetoothDevices() async {
    final paired = await PrintBluetoothThermal.pairedBluetooths;
    setState(() {
      pairedDevices = paired;
    });
  }

  Future<void> startPrinting(String mac) async {
    bool isConnected =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    log("Connected: $isConnected");

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to printer')),
      );
      return;
    }

    CapabilityProfile profile = await CapabilityProfile.load();
    final Generator generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Optional Logo (if needed)
    try {
      final ByteData data = await rootBundle.load("assets/app_logo.jpeg");
      final Uint8List imgBytes = data.buffer.asUint8List();
      final img.Image? image = img.decodeImage(imgBytes);
      if (image != null) {
        bytes += generator.image(image);
        bytes += generator.feed(1);
      }
    } catch (e) {
      log("Image load failed: $e");
    }

    bytes += generator.text('INVOICE: ${posData[0]["invoice"]}',
        styles: PosStyles(
            align: PosAlign.left, bold: true, height: PosTextSize.size2));
    bytes += generator.text('Date: ${posData[0]["date"]}');
    bytes += generator.text('Customer: ${posData[0]["customer"]}');
    bytes += generator.text('Sold By: ${posData[0]["sold_by"]}');
    bytes += generator.feed(1);

    // Items Header
    bytes += generator.row([
      PosColumn(text: 'Item', width: 6, styles: PosStyles(bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: PosStyles(bold: true)),
      PosColumn(text: 'Rate', width: 2, styles: PosStyles(bold: true)),
      PosColumn(text: 'Amt', width: 2, styles: PosStyles(bold: true)),
    ]);

    bytes += generator.hr();

    for (var item in posData[0]["items"]) {
      bytes += generator.row([
        PosColumn(text: item["name"], width: 6),
        PosColumn(text: item["qty"], width: 2),
        PosColumn(text: item["rate"].toStringAsFixed(0), width: 2),
        PosColumn(text: item["amount"].toStringAsFixed(0), width: 2),
      ]);
    }

    bytes += generator.hr();

    // Summary
    bytes += generator.text("Discount: ${posData[0]["discount"]}");
    bytes += generator.text("Shipping: ${posData[0]["shipping"]}");
    bytes += generator.text("Total: ${posData[0]["total"]}",
        styles: PosStyles(bold: true));
    bytes += generator.text("Paid: ${posData[0]["paid"]}");
    bytes += generator.text("Due: ${posData[0]["due"]}");
    bytes += generator.feed(1);

    // Payments
    bytes += generator.text("Payments:", styles: PosStyles(bold: true));
    for (var payment in posData[0]["payments"]) {
      bytes += generator.text(
          '${payment["txn_no"]} | ${payment["mode"]} | ${payment["date"]} | ₹${payment["amount"]}');
    }

    bytes += generator.feed(3);
    bytes += generator.cut();

    final result = await PrintBluetoothThermal.writeBytes(bytes);
    log("Print result: $result");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth POS Printer'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Invoice Data Display as Image Example
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Sale Invoice - Sample Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posData[0]["items"].length,
              itemBuilder: (context, index) {
                final item = posData[0]["items"][index];
                return ListTile(
                  title: Text(item["name"]),
                  subtitle: Text(
                    'Qty: ${item["qty"]} | Rate: ${item["rate"]} | Tax: ${item["tax"]} | Amount: ${item["amount"]}',
                    style: TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
          ),
        ],
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
            await showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Select Bluetooth Printer"),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: pairedDevices.length,
                        itemBuilder: (context, index) {
                          final device = pairedDevices[index];
                          return ListTile(
                            title: Text(device["name"]),
                            subtitle: Text(device["macAddress"]),
                            trailing: ElevatedButton(
                              child: const Text("Select & Print"),
                              onPressed: () async {
                                await startPrinting(device["macAddress"]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
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
    );
  }
}
