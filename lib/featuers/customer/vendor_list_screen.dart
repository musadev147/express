import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'vendor_product_screen.dart';
import '../../helpers/mock_db_service.dart';

class VendorListScreen extends StatelessWidget {
  final Map<String, dynamic>? product;
  final List<Map<String, dynamic>>? vendors;
  final String? productTag;

  const VendorListScreen({
    super.key,
    this.product,
    this.vendors,
    this.productTag,
  });

  void _callVendor(Map<String, dynamic> vendor, String prodName) {
    MockDbService.to.startCall(
      receiverPhone: vendor['phone'] ?? '',
      receiverName: vendor['name'] ?? '',
      receiverShopName: vendor['shopName'] ?? '',
      receiverArea: vendor['area'] ?? '',
      productName: prodName,
    );
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;
    String area = db.currentArea.value;

    String displayTag = productTag ?? product?['name'] ?? 'Product';
    String displayCategory = product?['category'] ?? 'All Categories';
    String displayPrice = product?['price'] != null ? "৳${product!['price']}" : "Local Store Pricing";

    // Resolve list of vendors
    List<Map<String, dynamic>> resolvedVendors = [];
    if (vendors != null) {
      resolvedVendors = vendors!;
    } else {
      String target = displayTag.trim().toLowerCase();
      resolvedVendors = db.vendors.where((v) {
        return v['area'] == area &&
            db.products.any((p) =>
                p['vendorPhone'] == v['phone'] &&
                ((p['tags'] != null && (p['tags'] as List).any((t) => t.toString().toLowerCase() == target)) ||
                    (p['subTags'] != null && (p['subTags'] as List).any((st) => st.toString().toLowerCase() == target)) ||
                    p['name'].toString().toLowerCase().contains(target)));
      }).toList();
    }

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
                    "Tag: $displayTag",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Pricing: $displayPrice • $displayCategory • Area: $area",
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                  ),
                ],
              ),
            ),

            // Vendor list
            Expanded(
              child: resolvedVendors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.storefront, size: 64, color: Color(0xFF6E6E86)),
                          SizedBox(height: 12.h),
                          Text(
                            "No vendors currently match '$displayTag' in $area.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF6E6E86)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: resolvedVendors.length,
                      itemBuilder: (context, index) {
                        var vendor = resolvedVendors[index];

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
                                          "Owner: ${vendor['name'] ?? ''}",
                                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                                        ),
                                        Text(
                                          "Area: ${vendor['area'] ?? area}",
                                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        displayPrice,
                                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                                      ),
                                      Text(
                                        "${vendor['distanceKm'] ?? 1.2} km away",
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
                                      onPressed: () => _callVendor(vendor, displayTag),
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
                                      child: const Text("View Products", style: TextStyle(color: Colors.white)),
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
