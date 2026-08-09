import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'vendor_product_screen.dart';
import '../../helpers/mock_db_service.dart';

class VendorListScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final List<Map<String, dynamic>> vendors;

  const VendorListScreen({super.key, required this.product, required this.vendors});

  void _callVendor(Map<String, dynamic> vendor) {
    MockDbService.to.startCall(
      receiverPhone: vendor['phone'] ?? '',
      receiverName: vendor['name'] ?? '',
      receiverShopName: vendor['shopName'] ?? '',
      receiverArea: vendor['area'] ?? '',
      productName: product['name'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Available Vendors", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top banner showing product info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              color: const Color(0xFF2563EB).withOpacity(0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product: ${product['name']}",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Estimated Price: ৳${product['price']} • Category: ${product['category']}",
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                  ),
                ],
              ),
            ),

            // Vendor list
            Expanded(
              child: vendors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.storefront, size: 64, color: Color(0xFF6E6E86)),
                          SizedBox(height: 12.h),
                          const Text(
                            "No vendors currently match this search in your area.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF6E6E86)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: vendors.length,
                      itemBuilder: (context, index) {
                        var vendor = vendors[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 24.r,
                                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                                    child: const Icon(Icons.store, color: Color(0xFF2563EB)),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vendor['shopName'] ?? 'Shop Name',
                                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                        ),
                                        Text(
                                          "Owner: ${vendor['name']}",
                                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                                        ),
                                        Text(
                                          "Area: ${vendor['area']}",
                                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "৳${product['price']}",
                                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                                      ),
                                      Text(
                                        "1.2 km away",
                                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6E6E86)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _callVendor(vendor),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF2563EB),
                                        side: const BorderSide(color: Color(0xFF2563EB)),
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                      ),
                                      icon: const Icon(Icons.phone),
                                      label: const Text("Call"),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.to(() => VendorProductScreen(vendor: vendor));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                        elevation: 0,
                                      ),
                                      child: const Text("View Products"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
