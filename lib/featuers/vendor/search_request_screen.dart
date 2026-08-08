import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../helpers/mock_db_service.dart';

class SearchRequestScreen extends StatelessWidget {
  const SearchRequestScreen({super.key});

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      DateTime dt = DateTime.parse(isoString);
      return DateFormat('hh:mm a, dd MMM').format(dt);
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
        title: const Text("Customer Product Requests", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          var area = db.currentUser['area'] ?? '';
          var localRequests = db.searchRequests.where((req) => req['area'] == area).toList();

          if (localRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none, size: 64, color: Color(0xFF6E6E86)),
                  SizedBox(height: 12.h),
                  const Text("No local product requests in your area.", style: TextStyle(color: Color(0xFF6E6E86))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: localRequests.length,
            itemBuilder: (context, index) {
              var req = localRequests[index];

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
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            "New Search Alert",
                            style: TextStyle(fontSize: 10.sp, color: const Color(0xFFDC2626), fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          _formatTime(req['time']),
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6E6E86)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Product requested: ${req['product']}",
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Customer Area: ${req['area']}",
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86)),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Check if product is already in catalog
                            String prodName = req['product'].toString();
                            var phone = db.currentUser['phone'];

                            var existing = db.products.firstWhere(
                              (p) => p['vendorPhone'] == phone && p['name'].toString().toLowerCase() == prodName.toLowerCase(),
                              orElse: () => <String, dynamic>{},
                            );

                            if (existing.isNotEmpty) {
                              existing['isAvailable'] = true;
                              existing['stock'] = (existing['stock'] ?? 0) + 10;
                              db.saveProduct(existing);
                              Fluttertoast.showToast(msg: "Stock updated for $prodName!");
                            } else {
                              db.saveProduct({
                                'id': 'p_${DateTime.now().millisecondsSinceEpoch}',
                                'name': prodName,
                                'category': 'Others',
                                'price': 100.0,
                                'stock': 10,
                                'unit': 'pcs',
                                'description': 'Added via customer search alert request',
                                'isAvailable': true,
                                'vendorPhone': phone
                              });
                              Fluttertoast.showToast(msg: "Added $prodName to your shop items!");
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF16A34A)),
                          label: const Text("I Have This Item", style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
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
