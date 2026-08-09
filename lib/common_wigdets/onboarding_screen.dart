import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../route/app_pages.dart';

class OnboardingScreen extends StatelessWidget {
  final dynamic selectedRole;
  const OnboardingScreen({super.key, this.selectedRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Mesh / Gradient Shapes
          Positioned(
            top: -100.h,
            right: -100.w,
            child: Container(
              width: 300.w,
              height: 300.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            left: -50.w,
            child: Container(
              width: 250.w,
              height: 250.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16A34A).withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo Representation
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(Icons.bolt, color: Colors.white, size: 40.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  Text(
                    "Welcome to Express",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Select a portal to explore local listings",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6E6E86),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Customer / Buyer card
                  _buildRoleCard(
                    title: "Customer",
                    subtitle: "Search products & vendors, order items locally",
                    badgeText: "Buyer",
                    icon: Icons.shopping_bag_rounded,
                    gradientColors: [const Color(0xFF2563EB), const Color(0xFF0EA5E9)],
                    onTap: () {
                      Get.toNamed(Routes.LOGIN, arguments: 'customer');
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Vendor / Seller card
                  _buildRoleCard(
                    title: "Vendor",
                    subtitle: "Manage inventory, receive orders & grow sales",
                    badgeText: "Seller",
                    icon: Icons.storefront_rounded,
                    gradientColors: [const Color(0xFF16A34A), const Color(0xFF10B981)],
                    onTap: () {
                      Get.toNamed(Routes.LOGIN, arguments: 'vendor');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            // Circular icon
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24.r),
            ),
            SizedBox(width: 16.w),
            
            // Text Block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Soft-styled pill badge instead of floating stack badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: gradientColors[0].withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: gradientColors[0].withOpacity(0.15)),
                        ),
                        child: Text(
                          badgeText.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: gradientColors[0],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6E6E86),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios, color: Color(0xFF0F172A), size: 12),
            ),
          ],
        ),
      ),
    );
  }
}
