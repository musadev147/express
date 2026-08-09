import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../helpers/mock_db_service.dart';
import '../route/app_pages.dart';

class ProfileScreen extends StatefulWidget {
  final int points;
  const ProfileScreen({super.key, this.points = 350});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RxBool _notificationsEnabled = true.obs;
  final RxString _selectedLanguage = "English".obs;

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, color: Colors.white, size: 30.r),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Express Premium VIP",
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Unlock ultimate benefits and priority features.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp),
                ),
                SizedBox(height: 16.h),
                _buildPremiumFeatureRow(Icons.flash_on, "Instant Tag-Search Calling"),
                _buildPremiumFeatureRow(Icons.support_agent, "24/7 Premium Support"),
                _buildPremiumFeatureRow(Icons.percent, "Exclusive VIP Discounts & Perks"),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Fluttertoast.showToast(msg: "Successfully Subscribed to Premium!");
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: const Text("Subscribe at ৳199/month", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Maybe Later", style: TextStyle(color: Color(0xFF64748B))),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumFeatureRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF59E0B), size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.white, fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select Language"),
          children: [
            SimpleDialogOption(
              onPressed: () {
                _selectedLanguage.value = "English";
                Get.back();
              },
              child: const Text("English (US)"),
            ),
            SimpleDialogOption(
              onPressed: () {
                _selectedLanguage.value = "বাংলা (Bengali)";
                Get.back();
              },
              child: const Text("বাংলা (Bengali)"),
            ),
          ],
        );
      },
    );
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text("About Us"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Express App", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4.h),
              const Text("Version 1.0.0 (Stable)", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 12.h),
              const Text("Express is the ultimate local tagging and fast calling commerce platform connecting buyers and sellers directly within local communities. Our mission is to make neighborhood transactions seamless, fast, and secure."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Close"),
            )
          ],
        );
      },
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text("Terms & Conditions"),
          content: const SingleChildScrollView(
            child: Text("Welcome to Express. By using this application, you agree to comply with our Terms of Service. Users are responsible for providing authentic contact details. Mock invoices are generated for demonstration purposes. We reserves the right to modify these terms at any time."),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Accept"),
            )
          ],
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text("Privacy Policy"),
          content: const SingleChildScrollView(
            child: Text("Your privacy is important to us. Express collects user phone numbers, areas, and shop names to facilitate direct calling and in-app invoice generation. We do not sell or share your personal data with third-party networks."),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Close"),
            )
          ],
        );
      },
    );
  }

  void _triggerPlayStoreRating() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text("Rate on Play Store"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 50),
              SizedBox(height: 12.h),
              const Text("Enjoying Express App?", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              const Text("Tap stars to rate us 5-stars on Google Play Store!"),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 30)),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Fluttertoast.showToast(msg: "Thank you for your rating!");
                Get.back();
              },
              child: const Text("Rate Now"),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog() {
    var db = MockDbService.to;
    var user = db.currentUser;
    bool isVendor = db.currentRole.value == 'vendor';

    final nameController = TextEditingController(text: user['name'] ?? '');
    final shopNameController = TextEditingController(text: user['shopName'] ?? '');
    final emailController = TextEditingController(text: user['email'] ?? '');
    final addressController = TextEditingController(text: user['address'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.r,
            left: 20.r,
            right: 20.r,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Edit Profile Details",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: isVendor ? "Owner Name" : "Customer Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                if (isVendor) ...[
                  SizedBox(height: 12.h),
                  TextField(
                    controller: shopNameController,
                    decoration: InputDecoration(
                      labelText: "Shop Name",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Shop Address",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ],
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      Fluttertoast.showToast(msg: "Name cannot be empty");
                      return;
                    }
                    db.updateUserProfile(
                      name: nameController.text.trim(),
                      shopName: isVendor ? shopNameController.text.trim() : null,
                      email: isVendor ? emailController.text.trim() : null,
                      address: isVendor ? addressController.text.trim() : null,
                    );
                    Fluttertoast.showToast(msg: "Profile updated successfully!");
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVendor ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: const Text("Save Details", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;
    return Obx(() {
      var user = db.currentUser;
      bool isVendor = db.currentRole.value == 'vendor';
      Color themeColor = isVendor ? const Color(0xFF16A34A) : const Color(0xFF2563EB);

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text("My Profile", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar & Profile Info Card
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.black.withOpacity(0.03)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46.r,
                      backgroundColor: themeColor.withOpacity(0.1),
                      child: Icon(
                        isVendor ? Icons.storefront : Icons.person,
                        size: 46.r,
                        color: themeColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user['name'] ?? user['shopName'] ?? 'Guest User',
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: _showEditProfileDialog,
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, color: themeColor, size: 13.r),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        isVendor ? "Seller Partner" : "Customer Account",
                        style: TextStyle(fontSize: 11.sp, color: themeColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Premium Express Gold Tier Membership Card
              GestureDetector(
                onTap: _showSubscriptionDialog,
                child: Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)], // Premium Gold gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.stars, color: Colors.white, size: 24.r),
                              SizedBox(width: 8.w),
                              Text(
                                "GOLD MEMBER TIER",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp, letterSpacing: 1.1),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              "PRO BENEFITS",
                              style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Loyalty Reward Points",
                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.sp),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "${widget.points} PTS",
                                style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Icon(Icons.chevron_right, color: Colors.white, size: 28.r),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Progress Bar to next tier
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: widget.points / 500.0,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6.h,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "150 PTS needed to reach Platinum Tier",
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Profile / Account Info Section
              Text(
                "Account Details",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
              ),
              SizedBox(height: 10.h),
              _buildCardSection([
                _buildRowItem(Icons.phone, "Phone Number", user['phone'] ?? 'N/A'),
                if (isVendor) ...[
                  _buildRowItem(Icons.store, "Shop Name", user['shopName'] ?? 'N/A'),
                  _buildRowItem(Icons.category, "Business Category", user['category'] ?? 'N/A'),
                  _buildRowItem(Icons.location_on, "Location Address", "${user['area'] ?? ''}, ${user['upazila'] ?? ''}"),
                ] else ...[
                  _buildRowItem(Icons.location_on, "Selected Area", "${db.currentArea.value}, ${db.currentUpazila.value}"),
                ],
              ]),

              SizedBox(height: 24.h),

              // Settings & Controls
              Text(
                "Preferences & Settings",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
              ),
              SizedBox(height: 10.h),
              _buildCardSection([
                _buildToggleItem(Icons.notifications_active_outlined, "Push Notifications", _notificationsEnabled),
                _buildActionItem(Icons.translate, "App Language", _selectedLanguage, _showLanguageDialog),
                _buildActionItem(Icons.verified_user_outlined, "Premium Subscription", "Manage Premium".obs, _showSubscriptionDialog),
              ]),

              SizedBox(height: 24.h),

              // Info & Legal Section
              Text(
                "Info & Legal",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
              ),
              SizedBox(height: 10.h),
              _buildCardSection([
                _buildActionItem(Icons.info_outline, "About Us", "".obs, _showAboutUsDialog),
                _buildActionItem(Icons.gavel, "Terms & Conditions", "".obs, _showTermsDialog),
                _buildActionItem(Icons.privacy_tip_outlined, "Privacy Policy", "".obs, _showPrivacyDialog),
                _buildActionItem(Icons.star_rate_outlined, "Rate on Play Store", "5 Stars".obs, _triggerPlayStoreRating),
              ]),

              SizedBox(height: 32.h),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  db.logout();
                  Get.offAllNamed(Routes.ONBOARDING);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout),
                label: Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCardSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) return children[index];
          return Column(
            children: [
              children[index],
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRowItem(IconData icon, String title, String val) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                SizedBox(height: 2.h),
                Text(val, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, RxBool state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ),
          Obx(() => Switch(
                value: state.value,
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) => state.value = val,
              )),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, RxString val, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 20.r),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ),
            Obx(() => Text(
                  val.value,
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                )),
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right, color: const Color(0xFF94A3B8), size: 18.r),
          ],
        ),
      ),
    );
  }
}
