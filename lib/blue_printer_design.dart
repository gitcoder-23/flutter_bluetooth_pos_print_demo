import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

class BluePrinterDesign extends StatefulWidget {
  const BluePrinterDesign({super.key});

  @override
  State<BluePrinterDesign> createState() => _BluePrinterDesignState();
}

class _BluePrinterDesignState extends State<BluePrinterDesign> {
  ReceiptController? controller;

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
        {
          "name": "VIVO F29 PRO 5G 8GB/256GB G.BLACK #IMEI-866658078758057",
          "qty": "1piece",
          "rate": 25322.88,
          "tax": "18%",
          "amount": 29099.00
        },
        {
          "name": "VIVO F29 PRO 5G 8GB/256GB G.BLACK #IMEI-866658078758057",
          "qty": "1piece",
          "rate": 25322.88,
          "tax": "18%",
          "amount": 29099.00
        },
        {
          "name": "VIVO F29 PRO 5G 8GB/256GB G.BLACK #IMEI-866658078758057",
          "qty": "1piece",
          "rate": 25322.88,
          "tax": "18%",
          "amount": 29099.00
        },
        {
          "name": "VIVO F29 PRO 5G 8GB/256GB G.BLACK #IMEI-866658078758057",
          "qty": "1piece",
          "rate": 25322.88,
          "tax": "18%",
          "amount": 29099.00
        },
        {
          "name": "VIVO F29 PRO 5G 8GB/256GB G.BLACK #IMEI-866658078758057",
          "qty": "1piece",
          "rate": 25322.88,
          "tax": "18%",
          "amount": 29099.00
        }
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
              final address =
                  await FlutterBluetoothPrinter.selectDevice(context);
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
          builder: (context) => Column(
            children: [
              // Header Section
              Text('INVOICE: ${posData[0]["invoice"]}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Date: ${posData[0]["date"]}',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
              Text('Customer: ${posData[0]["customer"]}',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
              Text('Sold By: ${posData[0]["sold_by"]}',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
              SizedBox(height: 5),

              // Items Table Header
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Item',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Qty',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Rate',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Tax',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Amount',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                  // Items Rows
                  for (var item in posData[0]["items"])
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(2),
                          child: Text(item["name"],
                              style: TextStyle(fontSize: 15)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(2),
                          child:
                              Text(item["qty"], style: TextStyle(fontSize: 15)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(2),
                          child: Text(item["rate"].toString(),
                              style: TextStyle(fontSize: 15)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(2),
                          child:
                              Text(item["tax"], style: TextStyle(fontSize: 15)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(2),
                          child: Text(item["amount"].toString(),
                              style: TextStyle(fontSize: 15)),
                        ),
                      ],
                    ),
                ],
              ),

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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${posData[0]["discount"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Shipping:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${posData[0]["shipping"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Total:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${posData[0]["total"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Paid:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${posData[0]["paid"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Due:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${posData[0]["due"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Mode',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Date',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Amount',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
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
          ),
          onInitialized: (controller) {
            this.controller = controller;
          },
        ));
  }
}
