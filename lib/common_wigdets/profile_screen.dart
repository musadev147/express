import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../helpers/mock_db_service.dart';
import '../route/app_pages.dart';

class ProfileScreen extends StatelessWidget {
  final int points;
  const ProfileScreen({super.key, this.points = 100});

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;
    return Obx(() {
      var user = db.currentUser;
      bool isVendor = db.currentRole.value == 'vendor';

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text("My Profile", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              // Avatar and Name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: isVendor ? const Color(0xFF16A34A).withOpacity(0.1) : const Color(0xFF2563EB).withOpacity(0.1),
                      child: Icon(
                        isVendor ? Icons.storefront : Icons.person,
                        size: 50.r,
                        color: isVendor ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      user['name'] ?? user['shopName'] ?? 'Guest User',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isVendor ? const Color(0xFF16A34A).withOpacity(0.1) : const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        isVendor ? "Seller Account" : "Buyer Account",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isVendor ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Details section
              _buildProfileItem(Icons.phone_android, "Phone Number", user['phone'] ?? 'N/A'),
              if (isVendor) ...[
                _buildProfileItem(Icons.shopping_bag, "Shop Name", user['shopName'] ?? 'N/A'),
                _buildProfileItem(Icons.category, "Category", user['category'] ?? 'N/A'),
                _buildProfileItem(Icons.email, "Email", user['email'] ?? 'N/A'),
                _buildProfileItem(Icons.location_on, "Location Area", "${user['area'] ?? ''}, ${user['upazila'] ?? ''}, ${user['district'] ?? ''}"),
              ] else ...[
                _buildProfileItem(
                  Icons.location_on,
                  "Current Selected Area",
                  "${db.currentArea.value}, ${db.currentUpazila.value}",
                ),
              ],

              SizedBox(height: 40.h),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  db.logout();
                  Get.offAllNamed(Routes.ONBOARDING);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout),
                label: Text("Sign Out", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6E6E86)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86))),
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
