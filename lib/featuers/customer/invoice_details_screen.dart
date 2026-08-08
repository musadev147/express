import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  String _formatDateTime(String? isoString) {
    if (isoString == null) return '';
    try {
      DateTime dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  void _shareReceipt() {
    String itemsText = '';
    for (var item in invoice['items']) {
      itemsText += "${item['name']} × ${item['qty']} @ ৳${item['price']}\n";
    }

    String shareContent = """
🧾 EXPRESS LOCAL MARKETPLACE RECEIPT
Invoice: ${invoice['id']}
Date: ${_formatDateTime(invoice['dateTime'])}

Customer: ${invoice['customerName']} (${invoice['customerPhone']})
Vendor: ${invoice['vendorShopName']} (${invoice['vendorArea']})

Products:
------------------------
$itemsText
------------------------
Subtotal: ৳${invoice['subtotal']}
Discount: ৳${invoice['discount']}
Total: ৳${invoice['total']}

Thank you for choosing local marketplace!
""";

    Share.share(shareContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Invoice ${invoice['id']}", style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              // Styled Invoice card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "INVOICE",
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6E6E86), letterSpacing: 1.0),
                            ),
                            Text(
                              invoice['id'] ?? 'INV-00000',
                              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            "PAID",
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF16A34A), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Date & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date & Time:", style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86))),
                        Text(
                          _formatDateTime(invoice['dateTime']),
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Customer Details
                    Text(
                      "Customer details:",
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6E6E86)),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      invoice['customerName'] ?? 'Customer',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    Text(
                      invoice['customerPhone'] ?? 'Phone',
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86)),
                    ),
                    const Divider(height: 32),

                    // Vendor Details
                    Text(
                      "Vendor details:",
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6E6E86)),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      invoice['vendorShopName'] ?? 'Shop',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    Text(
                      "Area: ${invoice['vendorArea'] ?? 'Area'}",
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86)),
                    ),
                    const Divider(height: 32),

                    // Products headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Product", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6E6E86))),
                        Text("Total", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6E6E86))),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Product list
                    ...List.generate(invoice['items'].length, (idx) {
                      var item = invoice['items'][idx];
                      double itemTotal = item['price'] * item['qty'];

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${item['name']} × ${item['qty']}",
                              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF0F172A)),
                            ),
                            Text(
                              "৳${itemTotal.toStringAsFixed(0)}",
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 32),

                    // Summary Block
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Subtotal", style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6E6E86))),
                        Text("৳${invoice['subtotal']}", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Discount", style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6E6E86))),
                        Text("৳${invoice['discount']}", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A))),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Grand Total", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text(
                          "৳${invoice['total']}",
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Fluttertoast.showToast(msg: "PDF Receipt generated inside downloads directory.");
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Download PDF"),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.share),
                      label: const Text("Share Invoice"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
