import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../constants/app_constants.dart';
import '../../helpers/di.dart';
import '../../helpers/mock_db_service.dart';
import '../../networks/api_acess.dart';
import '../../networks/dio/dio.dart';
import '../../networks/model/auth_model.dart';
import '../../route/app_pages.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final _ownerController = TextEditingController();
  final _shopController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? selectedDivision;
  String? selectedDistrict;
  String? selectedUpazila;
  String? selectedArea;
  String selectedCategory = 'Electronics';

  final List<String> categories = ['Electronics', 'Grocery', 'Medicine', 'Hardware', 'Clothing', 'Others'];

  @override
  void initState() {
    super.initState();
    var db = MockDbService.to;
    selectedDivision = db.divisions.first;
    selectedDistrict = db.districts[selectedDivision]!.first;
    selectedUpazila = db.upazilas[selectedDistrict]!.first;
    selectedArea = db.areas[selectedUpazila] != null ? db.areas[selectedUpazila]!.first : 'Local Area';
  }

  Future<void> _handleVendorRegistration() async {
    if (_ownerController.text.isEmpty ||
        _shopController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all required fields");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return;
    }

    EasyLoading.show(status: 'Registering Vendor...');
    try {
      var req = RegisterVendorRequest(
        name: _ownerController.text.trim(),
        shopName: _shopController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        password: _passwordController.text.trim(),
        category: selectedCategory,
        division: selectedDivision ?? 'Dhaka',
        district: selectedDistrict ?? 'Gazipur',
        upazila: selectedUpazila ?? 'Kaliganj',
        area: selectedArea ?? 'Kaliganj Bazar',
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : '${selectedArea ?? "Kaliganj Bazar"} Main Road',
      );

      var response = await registerVendorRx.registerVendor(req);
      EasyLoading.dismiss();
      if (response.success && response.data != null) {
        String token = response.data!.token;
        appData.write(kKeyAccessToken, token);
        appData.write(kKeyToken, token);
        DioSingleton.instance.update(token);

        MockDbService.to.registerVendor({
          'name': _ownerController.text.trim(),
          'shopName': _shopController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'division': selectedDivision,
          'district': selectedDistrict,
          'upazila': selectedUpazila,
          'area': selectedArea,
          'category': selectedCategory,
          'password': _passwordController.text.trim(),
        });

        Fluttertoast.showToast(msg: "Vendor registration successful!");
        Get.offAllNamed(Routes.NAV, arguments: 'vendor');
      } else {
        _fallbackLocalRegistration();
      }
    } catch (e) {
      EasyLoading.dismiss();
      _fallbackLocalRegistration();
    }
  }

  void _fallbackLocalRegistration() {
    var db = MockDbService.to;
    var success = db.registerVendor({
      'name': _ownerController.text.trim(),
      'shopName': _shopController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'division': selectedDivision,
      'district': selectedDistrict,
      'upazila': selectedUpazila,
      'area': selectedArea,
      'category': selectedCategory,
      'password': _passwordController.text.trim(),
    });

    if (success) {
      Fluttertoast.showToast(msg: "Vendor registration successful!");
      Get.offAllNamed(Routes.NAV, arguments: 'vendor');
    } else {
      Fluttertoast.showToast(msg: "Vendor with this mobile number already exists.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Floating back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 20.w,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 18),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60.h),
                  // Styled role header icon
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        color: const Color(0xFF16A34A),
                        size: 32.r,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    "Vendor Registration",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Register your shop details to get started",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6E6E86),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  TextField(
                    controller: _ownerController,
                    decoration: InputDecoration(
                      labelText: "Owner Name *",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _shopController,
                    decoration: InputDecoration(
                      labelText: "Shop / Business Name *",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Mobile Number *",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email (Optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: "Shop Address Details",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Division dropdown
                  Builder(
                    builder: (context) {
                      List<String> divList = db.divisions.toSet().toList();
                      if (selectedDivision == null || !divList.contains(selectedDivision)) {
                        selectedDivision = divList.isNotEmpty ? divList.first : 'Dhaka';
                      }

                      List<String> distList = db.getDistrictsFor(selectedDivision).toSet().toList();
                      if (selectedDistrict == null || !distList.contains(selectedDistrict)) {
                        selectedDistrict = distList.isNotEmpty ? distList.first : 'Dhaka';
                      }

                      List<String> upazilaList = db.getUpazilasFor(selectedDistrict).toSet().toList();
                      if (selectedUpazila == null || !upazilaList.contains(selectedUpazila)) {
                        selectedUpazila = upazilaList.isNotEmpty ? upazilaList.first : 'Sadar';
                      }

                      List<String> areaList = db.getAreasFor(selectedUpazila).toSet().toList();
                      if (selectedArea == null || !areaList.contains(selectedArea)) {
                        selectedArea = areaList.isNotEmpty ? areaList.first : 'Local Area';
                      }

                      return Column(
                        children: [
                          if (divList.isNotEmpty)
                            DropdownButtonFormField<String>(
                              key: ValueKey('vendor_div_$selectedDivision'),
                              value: selectedDivision,
                              decoration: InputDecoration(labelText: "Division", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                              items: divList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedDivision = val;
                                    var newDists = db.getDistrictsFor(val);
                                    selectedDistrict = newDists.isNotEmpty ? newDists.first : '';
                                    var newUpazilas = db.getUpazilasFor(selectedDistrict);
                                    selectedUpazila = newUpazilas.isNotEmpty ? newUpazilas.first : '';
                                    var newAreas = db.getAreasFor(selectedUpazila);
                                    selectedArea = newAreas.isNotEmpty ? newAreas.first : 'Local Area';
                                  });
                                }
                              },
                            ),
                          SizedBox(height: 12.h),

                          // District dropdown
                          if (distList.isNotEmpty) ...[
                            DropdownButtonFormField<String>(
                              key: ValueKey('vendor_dist_${selectedDivision}_$selectedDistrict'),
                              value: selectedDistrict,
                              decoration: InputDecoration(labelText: "District", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                              items: distList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedDistrict = val;
                                    var newUpazilas = db.getUpazilasFor(val);
                                    selectedUpazila = newUpazilas.isNotEmpty ? newUpazilas.first : '';
                                    var newAreas = db.getAreasFor(selectedUpazila);
                                    selectedArea = newAreas.isNotEmpty ? newAreas.first : 'Local Area';
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 12.h),
                          ],

                          // Upazila dropdown
                          if (upazilaList.isNotEmpty) ...[
                            DropdownButtonFormField<String>(
                              key: ValueKey('vendor_upazila_${selectedDistrict}_$selectedUpazila'),
                              value: selectedUpazila,
                              decoration: InputDecoration(labelText: "Upazila", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                              items: upazilaList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedUpazila = val;
                                    var newAreas = db.getAreasFor(val);
                                    selectedArea = newAreas.isNotEmpty ? newAreas.first : 'Local Area';
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 12.h),
                          ],

                          // Area dropdown
                          if (areaList.isNotEmpty) ...[
                            DropdownButtonFormField<String>(
                              key: ValueKey('vendor_area_${selectedUpazila}_$selectedArea'),
                              value: selectedArea,
                              decoration: InputDecoration(labelText: "Area / Village", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                              items: areaList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedArea = val;
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 12.h),
                          ],
                        ],
                      );
                    },
                  ),

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: categories.contains(selectedCategory) ? selectedCategory : categories.first,
                    decoration: InputDecoration(labelText: "Store Category", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                    items: categories.toSet().map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCategory = val ?? 'Others';
                      });
                    },
                  ),
                  SizedBox(height: 16.h),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  ElevatedButton(
                    onPressed: _handleVendorRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text("Create Account", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
