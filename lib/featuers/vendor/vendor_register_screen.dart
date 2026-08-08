import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';
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

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Vendor Registration", style: TextStyle(color: Color(0xFF0F172A))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _ownerController,
                decoration: InputDecoration(
                  labelText: "Owner Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _shopController,
                decoration: InputDecoration(
                  labelText: "Shop Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Street Address",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 20.h),

              // Area Selection Section
              Text(
                "Area / Location Management",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: 12.h),

              // Division dropdown
              DropdownButtonFormField<String>(
                value: selectedDivision,
                decoration: InputDecoration(labelText: "Division", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                items: db.divisions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedDivision = val;
                    selectedDistrict = db.districts[val]!.first;
                    selectedUpazila = db.upazilas[selectedDistrict] != null ? db.upazilas[selectedDistrict]!.first : null;
                    selectedArea = selectedUpazila != null && db.areas[selectedUpazila] != null ? db.areas[selectedUpazila]!.first : null;
                  });
                },
              ),
              SizedBox(height: 12.h),

              // District dropdown
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                decoration: InputDecoration(labelText: "District", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                items: db.districts[selectedDivision]!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedDistrict = val;
                    selectedUpazila = db.upazilas[val] != null ? db.upazilas[val]!.first : null;
                    selectedArea = selectedUpazila != null && db.areas[selectedUpazila] != null ? db.areas[selectedUpazila]!.first : null;
                  });
                },
              ),
              SizedBox(height: 12.h),

              // Upazila dropdown
              if (selectedDistrict != null && db.upazilas[selectedDistrict] != null) ...[
                DropdownButtonFormField<String>(
                  value: selectedUpazila,
                  decoration: InputDecoration(labelText: "Upazila", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                  items: db.upazilas[selectedDistrict]!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedUpazila = val;
                      selectedArea = val != null && db.areas[val] != null ? db.areas[val]!.first : 'Local Area';
                    });
                  },
                ),
                SizedBox(height: 12.h),
              ],

              // Area dropdown
              if (selectedUpazila != null && db.areas[selectedUpazila] != null) ...[
                DropdownButtonFormField<String>(
                  value: selectedArea,
                  decoration: InputDecoration(labelText: "Area / Village", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                  items: db.areas[selectedUpazila]!.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedArea = val;
                    });
                  },
                ),
                SizedBox(height: 12.h),
              ],

              // Category dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(labelText: "Store Category", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
                onPressed: () {
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
                    'password': _passwordController.text.trim()
                  });

                  if (success) {
                    Fluttertoast.showToast(msg: "Vendor registration successful!");
                    Get.offAllNamed(Routes.NAV, arguments: 'vendor');
                  } else {
                    Fluttertoast.showToast(msg: "Vendor with this mobile number already exists.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text("Create Account", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
