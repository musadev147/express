import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../helpers/mock_db_service.dart';
import '../../networks/api_acess.dart';
import '../../networks/model/search_demand_model.dart';

class SearchRequestScreen extends StatefulWidget {
  const SearchRequestScreen({super.key});

  @override
  State<SearchRequestScreen> createState() => _SearchRequestScreenState();
}

class _SearchRequestScreenState extends State<SearchRequestScreen> {
  List<SearchDemandItem> _apiRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var res = await vendorSearchRequestsRx.fetchAreaSearchRequests();
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          _apiRequests = res.data!;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      DateTime dt = DateTime.parse(isoString);
      return DateFormat('hh:mm a, dd MMM').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Customer Product Requests", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _apiRequests.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: _apiRequests.length,
                    itemBuilder: (context, index) {
                      var req = _apiRequests[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    "Live Demand Alert",
                                    style: TextStyle(fontSize: 10.sp, color: const Color(0xFFDC2626), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  _formatTime(req.time),
                                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6E6E86)),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "Product requested: ${req.product}",
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Customer Area: ${req.area}",
                              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86)),
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    db.saveProduct({
                                      'id': 'PROD-${DateTime.now().millisecondsSinceEpoch}',
                                      'name': req.product,
                                      'vendorPhone': db.currentUser['phone'],
                                      'tags': [req.product.toLowerCase()],
                                      'subTags': <String>[],
                                      'price': 0,
                                      'category': 'Others',
                                      'isAvailable': true,
                                    });
                                    Fluttertoast.showToast(msg: "Added '${req.product}' to your shop!");
                                    Get.back();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  ),
                                  icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                                  label: Text("I Have This Item", style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Obx(() {
                    var area = db.currentUser['area'] ?? '';
                    var localRequests = db.searchRequests.where((req) => req['area'] == area).toList();

                    if (localRequests.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_none, size: 64, color: Color(0xFF6E6E86)),
                            SizedBox(height: 12.h),
                            const Text("No local product requests in your area.", style: TextStyle(color: Color(0xFF6E6E86))),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: localRequests.length,
                      itemBuilder: (context, index) {
                        var req = localRequests[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.black.withOpacity(0.04)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      "New Search Alert",
                                      style: TextStyle(fontSize: 10.sp, color: const Color(0xFFDC2626), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    _formatTime(req['time']),
                                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6E6E86)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "Product requested: ${req['product']}",
                                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Customer Area: ${req['area']}",
                                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6E6E86)),
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      db.saveProduct({
                                        'id': 'PROD-${DateTime.now().millisecondsSinceEpoch}',
                                        'name': req['product'],
                                        'vendorPhone': db.currentUser['phone'],
                                        'tags': [req['product'].toString().toLowerCase()],
                                        'subTags': <String>[],
                                        'price': 0,
                                        'category': 'Others',
                                        'isAvailable': true,
                                      });
                                      Fluttertoast.showToast(msg: "Added '${req['product']}' to your shop tags!");
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF16A34A),
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                    ),
                                    icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                                    label: Text("I Have This Item", style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
      ),
    );
  }
}
