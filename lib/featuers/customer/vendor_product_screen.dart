import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';
import '../../networks/api_acess.dart';
import '../../networks/model/product_model.dart';
import 'invoice_creation_screen.dart';

class VendorProductScreen extends StatefulWidget {
  final Map<String, dynamic> vendor;

  const VendorProductScreen({super.key, required this.vendor});

  @override
  State<VendorProductScreen> createState() => _VendorProductScreenState();
}

class _VendorProductScreenState extends State<VendorProductScreen> {
  List<ProductResponse> _apiProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (widget.vendor['id'] != null) {
      int? vId = int.tryParse(widget.vendor['id'].toString());
      if (vId != null) {
        setState(() {
          _isLoading = true;
        });
        try {
          var res = await getVendorProductsRx.fetchVendorProducts(vId);
          if (res.success && res.data != null && res.data!.isNotEmpty) {
            setState(() {
              _apiProducts = res.data!;
              _isLoading = false;
            });
            return;
          }
        } catch (_) {}
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;
    var vendor = widget.vendor;

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
                        "${vendor['address'] ?? ''}, ${vendor['area'] ?? ''}",
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
                        "Proprietor: ${vendor['name'] ?? ''}",
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Products list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _apiProducts.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.all(16.r),
                          itemCount: _apiProducts.length,
                          itemBuilder: (context, idx) {
                            var prod = _apiProducts[idx];
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: Colors.black.withOpacity(0.04)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                                    child: const Icon(Icons.inventory_2, color: Color(0xFF2563EB), size: 20),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prod.name,
                                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "Price: ৳${prod.price.toStringAsFixed(0)} • Stock: ${prod.stock} ${prod.unit}",
                                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF16A34A), fontWeight: FontWeight.w600),
                                        ),
                                        if (prod.tags.isNotEmpty) ...[
                                          SizedBox(height: 6.h),
                                          Wrap(
                                            spacing: 6.w,
                                            runSpacing: 4.h,
                                            children: prod.tags.map((st) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(6.r),
                                                ),
                                                child: Text(
                                                  st,
                                                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF475569)),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.phone, color: Color(0xFF16A34A)),
                                    onPressed: () {
                                      db.startCall(
                                        receiverPhone: vendor['phone'] ?? '',
                                        receiverName: vendor['name'] ?? '',
                                        receiverShopName: vendor['shopName'] ?? '',
                                        receiverArea: vendor['area'] ?? '',
                                        productName: prod.name,
                                      );
                                      Fluttertoast.showToast(msg: "Calling ${vendor['shopName']} for ${prod.name}...");
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Obx(() {
                          var vendorProducts = db.products.where((p) => p['vendorPhone'] == vendor['phone']).toList();

                          if (vendorProducts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.tag_outlined, size: 64, color: Color(0xFF6E6E86)),
                                  SizedBox(height: 12.h),
                                  const Text("No products listed by this seller yet.", style: TextStyle(color: Color(0xFF6E6E86))),
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
                              List<dynamic> subTags = prod['tags'] ?? prod['subTags'] ?? [];

                              return Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                                      child: const Icon(Icons.sell, color: Color(0xFF2563EB), size: 18),
                                    ),
                                    SizedBox(width: 14.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tagName,
                                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                          ),
                                          if (prod['price'] != null) ...[
                                            SizedBox(height: 2.h),
                                            Text(
                                              "৳${prod['price']} • Stock: ${prod['stock'] ?? 0} ${prod['unit'] ?? 'pcs'}",
                                              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF16A34A), fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                          if (subTags.isNotEmpty) ...[
                                            SizedBox(height: 6.h),
                                            Wrap(
                                              spacing: 6.w,
                                              runSpacing: 4.h,
                                              children: subTags.map((st) {
                                                return Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(6.r),
                                                  ),
                                                  child: Text(
                                                    st.toString(),
                                                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF475569)),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.phone, color: Color(0xFF16A34A)),
                                      onPressed: () {
                                        db.startCall(
                                          receiverPhone: vendor['phone'] ?? '',
                                          receiverName: vendor['name'] ?? '',
                                          receiverShopName: vendor['shopName'] ?? '',
                                          receiverArea: vendor['area'] ?? '',
                                          productName: tagName,
                                        );
                                        Fluttertoast.showToast(msg: "Calling ${vendor['shopName']} for $tagName...");
                                      },
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
      bottomNavigationBar: Obx(() {
        if (db.cartItems.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: EdgeInsets.all(16.r),
          color: Colors.white,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => const InvoiceCreationScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            child: Text("Generate Invoice (${db.cartItems.length} items)"),
          ),
        );
      }),
    );
  }
}
