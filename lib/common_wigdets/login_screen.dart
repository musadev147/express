import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../helpers/mock_db_service.dart';
import '../route/app_pages.dart';
import '../featuers/vendor/vendor_register_screen.dart';


class SignInScreen extends StatefulWidget {
  final String role;
  const SignInScreen({super.key, required this.role});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegisteringCustomer = false;

  @override
  Widget build(BuildContext context) {
    bool isCustomer = widget.role == 'customer';
    Color primaryColor = isCustomer ? const Color(0xFF2563EB) : const Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.h),
              Text(
                _isRegisteringCustomer
                    ? "Create Customer Account"
                    : "${widget.role.capitalizeFirst} Sign In",
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _isRegisteringCustomer
                    ? "Enter details to register"
                    : "Welcome back! Enter your details to continue",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6E6E86),
                ),
              ),
              SizedBox(height: 40.h),

              if (_isRegisteringCustomer) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  hintText: "e.g. 017XXXXXXXX",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              SizedBox(height: 16.h),

              if (!_isRegisteringCustomer)
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password / OTP",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),

              SizedBox(height: 24.h),

              ElevatedButton(
                onPressed: () {
                  String phone = _phoneController.text.trim();
                  if (phone.isEmpty) {
                    Fluttertoast.showToast(msg: "Please enter phone number");
                    return;
                  }

                  if (_isRegisteringCustomer) {
                    String name = _nameController.text.trim();
                    if (name.isEmpty) {
                      Fluttertoast.showToast(msg: "Please enter name");
                      return;
                    }
                    MockDbService.to.registerCustomer(phone, name);
                    Fluttertoast.showToast(msg: "Registration Successful!");
                    Get.offAllNamed(Routes.NAV, arguments: MockDbService.to.currentRole.value);
                  } else {
                    String password = _passwordController.text.trim();
                    if (isCustomer) {
                      MockDbService.to.signIn(phone, password, 'customer');
                      Fluttertoast.showToast(msg: "Welcome Customer!");
                      Get.offAllNamed(Routes.NAV, arguments: 'customer');
                    } else {
                      if (password.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter password");
                        return;
                      }
                      bool success = MockDbService.to.signIn(phone, password, 'vendor');
                      if (success) {
                        Fluttertoast.showToast(msg: "Welcome Back Seller!");
                        Get.offAllNamed(Routes.NAV, arguments: 'vendor');
                      } else {
                        Fluttertoast.showToast(msg: "Invalid vendor credentials. Check details or register!");
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isRegisteringCustomer ? "Create Account" : "Login",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 20.h),

              if (isCustomer) ...[
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegisteringCustomer = !_isRegisteringCustomer;
                    });
                  },
                  child: Text(
                    _isRegisteringCustomer ? "Already have an account? Sign In" : "Don't have an account? Create Account",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ] else ...[
                TextButton(
                  onPressed: () {
                    // Navigate to Vendor registration
                    Get.to(() => const VendorRegisterScreen());
                  },
                  child: Text(
                    "Don't have a vendor account? Register Shop",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],

              TextButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "Use '123' as default password/OTP for demo.");
                },
                child: const Text(
                  "Forgot Password / Need Help?",
                  style: TextStyle(color: Color(0xFF6E6E86)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

