import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../helpers/mock_db_service.dart';
import 'invoice_details_screen.dart';

class CustomerInvoicesScreen extends StatelessWidget {
  const CustomerInvoicesScreen({super.key});

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      DateTime dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("My Invoices", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          var customerInvoices = db.invoices.where((inv) {
            return inv['customerPhone'] == db.currentUser['phone'];
          }).toList();

          if (customerInvoices.isEmpty && db.currentUser['phone'] != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              db.invoices.addAll([
                {
                  'id': 'INV-95001',
                  'customerPhone': db.currentUser['phone'],
                  'customerName': db.currentUser['name'] ?? 'Regular Customer',
                  'vendorPhone': '01711111111',
                  'vendorShopName': 'Rahman Electronics',
                  'vendorArea': 'Kaliganj Bazar',
                  'items': [
                    {'id': 'p1', 'name': 'Sample Product X', 'price': 500.0, 'qty': 1},
                    {'id': 'p2', 'name': 'Sample Product Y', 'price': 150.0, 'qty': 2}
                  ],
                  'subtotal': 800.0,
                  'discount': 0.0,
                  'total': 800.0,
                  'dateTime': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
                }
              ]);
              db.saveInvoices();
            });
          }

          if (customerInvoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF6E6E86)),
                  SizedBox(height: 12.h),
                  const Text("No invoices generated yet.", style: TextStyle(color: Color(0xFF6E6E86))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: customerInvoices.length,
            itemBuilder: (context, index) {
              var invoice = customerInvoices[index];

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice['id'] ?? 'INV-00000',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Vendor: ${invoice['vendorShopName']}",
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                          ),
                          Text(
                            "Date: ${_formatDate(invoice['dateTime'])}",
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "৳${invoice['total']}",
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => InvoiceDetailsScreen(invoice: invoice));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            elevation: 0,
                          ),
                          child: Text("View", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
