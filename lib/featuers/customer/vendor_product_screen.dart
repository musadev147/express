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
                        const Icon(Icons.tag_outlined, size: 64, color: Color(0xFF6E6E86)),
                        SizedBox(height: 12.h),
                        const Text("No tags listed by this seller.", style: TextStyle(color: Color(0xFF6E6E86))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: vendorProducts.length,
                  itemBuilder: (context, idx) {
                    var prod = vendorProducts[idx];
                    String tagName = prod['name'] ?? '';
                    List<dynamic> subTags = prod['subTags'] ?? [];

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.label_important, color: Color(0xFF2563EB)),
                                  SizedBox(width: 6.w),
                                  Text(
                                    tagName.toUpperCase(),
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  db.startCall(
                                    receiverPhone: vendor['phone'],
                                    receiverName: vendor['name'],
                                    receiverShopName: vendor['shopName'],
                                    receiverArea: vendor['area'],
                                    productName: tagName.toUpperCase(),
                                  );
                                  Fluttertoast.showToast(msg: "Calling ${vendor['shopName']} for $tagName...");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                ),
                                icon: const Icon(Icons.phone, size: 12),
                                label: const Text("Call", style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          if (subTags.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 4.h,
                              children: subTags.map((sub) {
                                return ActionChip(
                                  label: Text(
                                    sub.toString().toUpperCase(),
                                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                                  ),
                                  backgroundColor: const Color(0xFF2563EB).withOpacity(0.06),
                                  onPressed: () {
                                    db.startCall(
                                      receiverPhone: vendor['phone'],
                                      receiverName: vendor['name'],
                                      receiverShopName: vendor['shopName'],
                                      receiverArea: vendor['area'],
                                      productName: sub.toString().toUpperCase(),
                                    );
                                    Fluttertoast.showToast(msg: "Calling ${vendor['shopName']} for $sub...");
                                  },
                                );
                              }).toList(),
                            ),
                          ],
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
    );
  }
}
