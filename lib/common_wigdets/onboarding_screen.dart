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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome to Express",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Choose your portal to continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6E6E86),
                ),
              ),
              SizedBox(height: 48.h),

              // Customer / Buyer card
              _buildRoleCard(
                title: "Customer / Buyer",
                subtitle: "Search products and vendors, order items locally",
                icon: Icons.shopping_bag_outlined,
                gradientColors: [const Color(0xFF2563EB), const Color(0xFF0EA5E9)],
                onTap: () {
                  Get.toNamed(Routes.LOGIN, arguments: 'customer');
                },
              ),

              SizedBox(height: 20.h),

              // Vendor / Seller card
              _buildRoleCard(
                title: "Vendor / Seller",
                subtitle: "Manage inventory, receive orders, and grow business",
                icon: Icons.storefront_outlined,
                gradientColors: [const Color(0xFF16A34A), const Color(0xFF10B981)],
                onTap: () {
                  Get.toNamed(Routes.LOGIN, arguments: 'vendor');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6E6E86),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF87878A), size: 16),
          ],
        ),
      ),
    );
  }
}
