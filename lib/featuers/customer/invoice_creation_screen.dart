import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';
import 'invoice_details_screen.dart';

class InvoiceCreationScreen extends StatelessWidget {
  const InvoiceCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Create Invoice", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (db.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF6E6E86)),
                  SizedBox(height: 12.h),
                  const Text("Your invoice cart is empty", style: TextStyle(color: Color(0xFF6E6E86))),
                ],
              ),
            );
          }

          double subtotal = 0;
          for (var item in db.cartItems) {
            subtotal += item['price'] * item['qty'];
          }

          return Column(
            children: [
              // Shop Header Info
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Vendor: ${db.cartItems[0]['vendorShopName']}",
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    Text(
                      "Area: ${db.cartItems[0]['vendorArea']}",
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Item List headers
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                color: const Color(0xFFF1F5F9),
                child: Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: Text("Product", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF475569)))),
                    Expanded(
                        flex: 3,
                        child:
                            Text("Qty", textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF475569)))),
                    Expanded(
                        flex: 2,
                        child:
                            Text("Price", textAlign: TextAlign.right, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF475569)))),
                    Expanded(
                        flex: 2,
                        child:
                            Text("Total", textAlign: TextAlign.right, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF475569)))),
                  ],
                ),
              ),

              // Cart Items
              Expanded(
                child: ListView.builder(
                  itemCount: db.cartItems.length,
                  itemBuilder: (context, idx) {
                    var item = db.cartItems[idx];
                    double itemTotal = item['price'] * item['qty'];

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                                Text("৳${item['price']}", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6E6E86))),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF6E6E86), size: 20),
                                  onPressed: () => db.updateCartQty(item['id'], item['qty'] - 1),
                                ),
                                Text("${item['qty']}", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2563EB), size: 20),
                                  onPressed: () => db.updateCartQty(item['id'], item['qty'] + 1),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "৳${item['price']}",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "৳${itemTotal.toStringAsFixed(0)}",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Summary card at bottom
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Subtotal", style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6E6E86))),
                        Text("৳${subtotal.toStringAsFixed(0)}", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Discount", style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6E6E86))),
                        Text("৳0", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A))),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Grand Total", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text("৳${subtotal.toStringAsFixed(0)}", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          var newInvoice = db.generateInvoice();
                          if (newInvoice.isNotEmpty) {
                            Fluttertoast.showToast(msg: "Invoice Generated successfully!");
                            Get.off(() => InvoiceDetailsScreen(invoice: newInvoice));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0,
                        ),
                        child: Text("Generate Invoice", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
