import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'dart:developer';
import 'package:flutter_html/flutter_html.dart';

class BluePrintScreenNew extends StatefulWidget {
  const BluePrintScreenNew({super.key});

  @override
  State<BluePrintScreenNew> createState() => _BluePrintScreenNewState();
}

class _BluePrintScreenNewState extends State<BluePrintScreenNew> {
  ReceiptController? controller;

  final receiptData = [
    {
      "description": """
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Invoice - SALE-348</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f2f2f2;
      padding: 20px;
    }
    .invoice-box {
      background: white;
      max-width: 800px;
      margin: auto;
      padding: 30px;
      border: 1px solid #eee;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.15);
    }
    .center {
      text-align: center;
    }
    .bold {
      font-weight: bold;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
    }
    table th, table td {
      border: 1px solid #ddd;
      padding: 8px;
      vertical-align: top;
    }
    table th {
      background-color: #f9f9f9;
    }
    .no-border {
      border: none;
    }
    .text-right {
      text-align: right;
    }
    .barcode {
      text-align: center;
      margin-top: 30px;
    }
    .footer {
      margin-top: 20px;
      text-align: center;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="invoice-box">
    <div class="center">
      <img src="https://i.imgur.com/z5q0qZz.png" height="50" alt="Logo" />
      <h2>MAKARDAH</h2>
      <p>Makardah, Howrah, West Bengal 711409</p>
      <p><strong>Phone:</strong> 9038000700</p>
      <p><strong>Email:</strong> wesoujanya@gmail.com</p>
    </div>

    <h3 class="center">TAX INVOICE</h3>
    <table class="no-border">
      <tr class="no-border">
        <td class="no-border"><strong>Invoice:</strong> SALE-348</td>
        <td class="no-border text-right"><strong>Date:</strong> 07-05-2025</td>
      </tr>
      <tr class="no-border">
        <td class="no-border"><strong>Customer:</strong> ANISHA KHATUN</td>
        <td class="no-border text-right"><strong>Sold By:</strong> @SOUJANYA_360DEGREE</td>
      </tr>
    </table>

    <table>
      <thead>
        <tr>
          <th># Item</th>
          <th>Qty</th>
          <th>Rate</th>
          <th>Tax</th>
          <th>Amount</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>1 COFFEE MUG #1213<br/>OPPO F29 PRO 5G 8GB/256GB</td>
          <td>1 piece</td>
          <td>₹1.00</td>
          <td>0%</td>
          <td>₹1.00</td>
        </tr>
        <tr>
          <td>2 G.BLACK #IMEI-866658078758057</td>
          <td>1 piece</td>
          <td>₹25,422.88</td>
          <td>18%</td>
          <td>₹29,999.00</td>
        </tr>
      </tbody>
    </table>

    <table class="no-border">
      <tr>
        <td class="no-border text-right"><strong>Discount:</strong> ₹2,300.00</td>
      </tr>
      <tr>
        <td class="no-border text-right"><strong>Shipping:</strong> ₹0.00</td>
      </tr>
    </table>

    <h3><strong>Items:</strong> 2 &nbsp;&nbsp; <strong>Qty:</strong> 2 &nbsp;&nbsp; <strong>Total:</strong> ₹27,700.00</h3>

    <table>
      <tr>
        <th>Paid Amount</th>
        <th>Due Amount</th>
      </tr>
      <tr>
        <td>₹27,700.00</td>
        <td>₹0.00</td>
      </tr>
    </table>

    <h4>Transactions</h4>
    <table>
      <thead>
        <tr>
          <th>Txns No.</th>
          <th>Payment Date</th>
          <th>Amount</th>
          <th>Payment Mode</th>
          <th>Notes</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>PAY-IN-279</td>
          <td>07-05-2025</td>
          <td>₹1,700.00</td>
          <td>UPI</td>
          <td>N/A</td>
        </tr>
        <tr>
          <td>PAY-IN-278</td>
          <td>07-05-2025</td>
          <td>₹26,000.00</td>
          <td>Cash</td>
          <td>N/A</td>
        </tr>
      </tbody>
    </table>

    <div class="barcode">
      <p>|||||||||||||||||||||</p>
      <p><strong>SALE-348</strong></p>
    </div>

    <div class="footer">
      Thank You For Shopping With Us. Please Come Again
    </div>
  </div>
</body>
</html>
"""
    }
  ];

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
        builder: (context) => SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                Image.asset('assets/app_logo.jpeg'),
                Html(
                  data: receiptData[0]["description"], // Your HTML invoice
                ),
              ],
            ),
          ),
        ),
        onInitialized: (controller) {
          this.controller = controller;
        },
      ),
    );
  }
}
