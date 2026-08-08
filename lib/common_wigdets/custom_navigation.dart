import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../helpers/mock_db_service.dart';
import '../featuers/customer/customer_home_screen.dart';
import '../featuers/customer/product_search_screen.dart';
import '../featuers/customer/customer_invoices_screen.dart';
import 'profile_screen.dart';
import '../featuers/vendor/vendor_dashboard_screen.dart';
import '../featuers/vendor/vendor_product_mgmt_screen.dart';
import '../featuers/vendor/vendor_invoices_screen.dart';

class CustomNavigation extends StatefulWidget {
  final String? role;
  final int selectedIndex;

  const CustomNavigation({super.key, this.role, this.selectedIndex = 0});

  @override
  State<CustomNavigation> createState() => _CustomNavigationState();
}

class _CustomNavigationState extends State<CustomNavigation> {
  final RxInt _selectedIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _selectedIndex.value = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Obx(() {
      bool isVendor = db.currentRole.value == 'vendor';

      // Set up screens and tab items per role
      List<Widget> screens = [];
      List<BottomNavItem> items = [];

      if (isVendor) {
        screens = [
          VendorDashboardScreen(
            onTabChange: (index) {
              _selectedIndex.value = index;
            },
          ),
          const VendorProductMgmtScreen(),
          const VendorInvoicesScreen(),
          const ProfileScreen(),
        ];
        items = [
          BottomNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: "Dashboard"),
          BottomNavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: "Products"),
          BottomNavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: "Invoices"),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: "Profile"),
        ];
      } else {
        screens = [
          const CustomerHomeScreen(),
          const ProductSearchScreen(),
          const CustomerInvoicesScreen(),
          const ProfileScreen(),
        ];
        items = [
          BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: "Home"),
          BottomNavItem(icon: Icons.search_outlined, activeIcon: Icons.search, label: "Search"),
          BottomNavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: "Invoices"),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: "Profile"),
        ];
      }

      if (_selectedIndex.value >= screens.length) {
        _selectedIndex.value = 0;
      }

      Color primaryColor = isVendor ? const Color(0xFF16A34A) : const Color(0xFF2563EB);

      return WillPopScope(
        onWillPop: () async {
          final shouldExit = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.logout, color: primaryColor, size: 30.r),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Exit App",
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 8.h),
                      const Text(
                        "Are you sure you want to exit?",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6E6E86)),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              child: const Text("No"),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              child: const Text("Yes"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          return shouldExit ?? false;
        },
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex.value,
            children: screens,
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (idx) {
                  bool isSelected = _selectedIndex.value == idx;
                  var item = items[idx];

                  return GestureDetector(
                    onTap: () => _selectedIndex.value = idx,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? primaryColor : const Color(0xFF87878A),
                            size: 24.r,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? primaryColor : const Color(0xFF87878A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  BottomNavItem({required this.icon, required this.activeIcon, required this.label});
}
