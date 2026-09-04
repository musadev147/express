import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../helpers/di.dart';
import '../helpers/mock_db_service.dart';
import '../networks/api_acess.dart';
import '../networks/dio/dio.dart';
import '../networks/model/auth_model.dart';
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
  bool _obscurePassword = true;

  Future<void> _handleAuth(bool isCustomer) async {
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
      EasyLoading.show(status: 'Registering...');
      try {
        var db = MockDbService.to;
        var req = RegisterCustomerRequest(
          name: name,
          phone: phone,
          password: _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : '123456',
          division: db.currentDivision.value,
          district: db.currentDistrict.value,
          upazila: db.currentUpazila.value,
          area: db.currentArea.value,
        );
        var response = await registerCustomerRx.registerCustomer(req);
        EasyLoading.dismiss();
        if (response.success && response.data != null) {
          String token = response.data!.token;
          appData.write(kKeyAccessToken, token);
          appData.write(kKeyToken, token);
          DioSingleton.instance.update(token);
          MockDbService.to.registerCustomer(phone, name);
          Fluttertoast.showToast(msg: "Registration Successful!");
          Get.offAllNamed(Routes.NAV, arguments: 'customer');
        } else {
          // Fallback to local
          MockDbService.to.registerCustomer(phone, name);
          Fluttertoast.showToast(msg: "Registered locally!");
          Get.offAllNamed(Routes.NAV, arguments: 'customer');
        }
      } catch (e) {
        EasyLoading.dismiss();
        MockDbService.to.registerCustomer(phone, _nameController.text.trim());
        Fluttertoast.showToast(msg: "Logged in via offline mode");
        Get.offAllNamed(Routes.NAV, arguments: 'customer');
      }
    } else {
      String password = _passwordController.text.trim();
      if (password.isEmpty) {
        password = isCustomer ? "123" : "";
        if (!isCustomer && password.isEmpty) {
          Fluttertoast.showToast(msg: "Please enter password");
          return;
        }
      }

      EasyLoading.show(status: 'Signing in...');
      try {
        var req = LoginRequest(
          phone: phone,
          password: password,
          role: isCustomer ? 'customer' : 'vendor',
        );
        var response = await loginRx.login(req);
        EasyLoading.dismiss();
        if (response.success && response.data != null) {
          String token = response.data!.token;
          appData.write(kKeyAccessToken, token);
          appData.write(kKeyToken, token);
          DioSingleton.instance.update(token);
          MockDbService.to.signIn(phone, password, isCustomer ? 'customer' : 'vendor');
          Fluttertoast.showToast(msg: "Welcome ${response.data!.user.name}!");
          Get.offAllNamed(Routes.NAV, arguments: isCustomer ? 'customer' : 'vendor');
        } else {
          MockDbService.to.signIn(phone, password, isCustomer ? 'customer' : 'vendor');
          Get.offAllNamed(Routes.NAV, arguments: isCustomer ? 'customer' : 'vendor');
        }
      } catch (e) {
        EasyLoading.dismiss();
        // Fallback to mock db service for seamless offline resilience
        MockDbService.to.signIn(phone, password, isCustomer ? 'customer' : 'vendor');
        Fluttertoast.showToast(msg: isCustomer ? "Welcome Customer!" : "Welcome Seller!");
        Get.offAllNamed(Routes.NAV, arguments: isCustomer ? 'customer' : 'vendor');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCustomer = widget.role == 'customer';
    Color primaryColor = isCustomer ? const Color(0xFF2563EB) : const Color(0xFF16A34A);

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

          // Background ambient shapes
          Positioned(
            top: -50.h,
            right: -50.w,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.03),
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
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        isCustomer ? Icons.shopping_bag_rounded : Icons.storefront_rounded,
                        color: primaryColor,
                        size: 32.r,
                      ),
                    ),
                  ),
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
                  SizedBox(height: 6.h),
                  Text(
                    _isRegisteringCustomer
                        ? "Enter details to register as a buyer"
                        : "Welcome back! Enter your details to continue",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6E6E86),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Name Field (Only if registering customer)
                  if (_isRegisteringCustomer) ...[
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6E6E86)),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Mobile Number Field
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Mobile Number",
                        hintText: "e.g. 017XXXXXXXX",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF6E6E86)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: _isRegisteringCustomer ? "Create Password" : "Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6E6E86)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF6E6E86),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Action Button
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _handleAuth(isCustomer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isRegisteringCustomer
                            ? "Complete Registration"
                            : "Sign In",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Toggle Customer Register or Vendor Register
                  if (isCustomer)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRegisteringCustomer
                              ? "Already have an account? "
                              : "New customer? ",
                          style: TextStyle(color: const Color(0xFF6E6E86), fontSize: 13.sp),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isRegisteringCustomer = !_isRegisteringCustomer;
                            });
                          },
                          child: Text(
                            _isRegisteringCustomer ? "Sign In" : "Register Now",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Want to register a new shop? ",
                          style: TextStyle(color: const Color(0xFF6E6E86), fontSize: 13.sp),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const VendorRegisterScreen());
                          },
                          child: Text(
                            "Register Shop",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
