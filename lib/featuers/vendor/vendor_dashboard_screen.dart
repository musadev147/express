import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';
import 'vendor_product_mgmt_screen.dart';
import 'search_request_screen.dart';

class VendorDashboardScreen extends StatelessWidget {
  final Function(int)? onTabChange;

  const VendorDashboardScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Seller Dashboard", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Color(0xFF16A34A)),
            onPressed: () {
              Get.to(() => const SearchRequestScreen());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Obx(() {
                var user = db.currentUser;
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF16A34A), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good Morning,",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.8)),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user['shopName'] ?? 'Seller Shop',
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.white70),
                          SizedBox(width: 4.w),
                          Text(
                            "Area: ${user['area'] ?? 'Not set'}",
                            style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 24.h),

              // Summary Title
              Text(
                "Today's Summary",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: 12.h),

              // Statistics Cards
              Obx(() {
                var phone = db.currentUser['phone'];
                var myProducts = db.products.where((p) => p['vendorPhone'] == phone).toList();
                var myInvoices = db.invoices.where((inv) => inv['vendorPhone'] == phone).toList();

                // Extract unique tags count
                var allTags = <String>{};
                for (var p in myProducts) {
                  List<dynamic> tagsList = p['tags'] ?? [];
                  for (var t in tagsList) {
                    if (t.toString().trim().isNotEmpty) {
                      allTags.add(t.toString().trim().toUpperCase());
                    }
                  }
                }
                var myTagsCount = allTags.length;

                double totalSales = 0;
                for (var inv in myInvoices) {
                  totalSales += inv['total'] ?? 0;
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Active Tags",
                            "$myTagsCount",
                            Icons.tag,
                            const Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildStatCard(
                            "Total Invoices",
                            "${myInvoices.length}",
                            Icons.receipt_long,
                            const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Sales Value",
                                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86)),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "৳${totalSales.toStringAsFixed(0)}",
                                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor: const Color(0xFF16A34A).withOpacity(0.1),
                            child: const Icon(Icons.monetization_on, color: Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),

              SizedBox(height: 28.h),

              // Quick Actions
              Text(
                "Quick Actions",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      "Manage Tags",
                      Icons.tag,
                      const Color(0xFF16A34A),
                      () {
                        Get.to(() => const VendorProductMgmtScreen());
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildActionButton(
                      "My Wallet",
                      Icons.account_balance_wallet,
                      const Color(0xFF2563EB),
                      () {
                        if (onTabChange != null) {
                          onTabChange!(1); // Go to Wallet tab (index 1)
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildActionButton(
                      "Invoices",
                      Icons.receipt,
                      const Color(0xFFF59E0B),
                      () {
                        if (onTabChange != null) {
                          onTabChange!(2); // Go to Invoices tab (index 2)
                        }
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Search requests notification card helper
              Obx(() {
                var area = db.currentUser['area'] ?? '';
                var localAlerts = db.searchRequests.where((req) => req['area'] == area).toList();

                if (localAlerts.isNotEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer Search Alerts!",
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              ),
                              Text(
                                "There are ${localAlerts.length} product searches in your area.",
                                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const SearchRequestScreen());
                          },
                          child: const Text("View", style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          SizedBox(height: 12.h),
          Text(
            count,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28.r),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
          ],
        ),
      ),
    );
  }
}
