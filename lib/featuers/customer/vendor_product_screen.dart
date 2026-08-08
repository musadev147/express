import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';
import 'invoice_creation_screen.dart';

class VendorProductScreen extends StatelessWidget {
  final Map<String, dynamic> vendor;

  const VendorProductScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(vendor['shopName'] ?? "Shop Products", style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Vendor details card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor['shopName'] ?? 'Shop Name',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF6E6E86)),
                      SizedBox(width: 4.w),
                      Text(
                        "${vendor['address']}, ${vendor['area']}",
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86)),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Color(0xFF6E6E86)),
                      SizedBox(width: 4.w),
                      Text(
                        "Proprietor: ${vendor['name']}",
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Products list
            Expanded(
              child: Obx(() {
                var vendorProducts = db.products.where((p) => p['vendorPhone'] == vendor['phone']).toList();

                if (vendorProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF6E6E86)),
                        SizedBox(height: 12.h),
                        const Text("No products cataloged by this seller.", style: TextStyle(color: Color(0xFF6E6E86))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: vendorProducts.length,
                  itemBuilder: (context, idx) {
                    var prod = vendorProducts[idx];
                    bool inStock = prod['isAvailable'] == true && (prod['stock'] ?? 0) > 0;

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
                                  prod['name'] ?? 'Product Name',
                                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "৳${prod['price']} per ${prod['unit'] ?? 'pcs'}",
                                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2563EB), fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: inStock ? const Color(0xFF16A34A).withOpacity(0.1) : const Color(0xFFDC2626).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    inStock ? "Available (Stock: ${prod['stock']})" : "Out of Stock",
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: inStock ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: inStock
                                ? () {
                                    db.addToCart(prod, vendor);
                                    Fluttertoast.showToast(msg: "${prod['name']} added to invoice");
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text("Add"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (db.cartItems.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => const InvoiceCreationScreen());
          },
          backgroundColor: const Color(0xFF2563EB),
          icon: const Icon(Icons.receipt_long),
          label: Text("Create Invoice (${db.cartItems.length})"),
        );
      }),
    );
  }
}
