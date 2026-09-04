import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';
import '../../networks/api_acess.dart';
import '../../networks/model/vendor_model.dart';
import 'product_search_screen.dart';
import 'vendor_product_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _searchController = TextEditingController();
  List<VendorMarketplaceItem> _apiVendors = [];
  bool _isLoadingVendors = false;

  @override
  void initState() {
    super.initState();
    _loadLocationHierarchy();
    _fetchNearbyVendors();
  }

  Future<void> _loadLocationHierarchy() async {
    try {
      await locationHierarchyRx.fetchHierarchy();
    } catch (_) {}
  }

  Future<void> _fetchNearbyVendors() async {
    setState(() {
      _isLoadingVendors = true;
    });
    try {
      var area = MockDbService.to.currentArea.value;
      var response = await getVendorsRx.fetchVendors(area: area);
      if (response.success && response.data != null) {
        setState(() {
          _apiVendors = response.data!;
          _isLoadingVendors = false;
        });
        return;
      }
    } catch (_) {}
    setState(() {
      _isLoadingVendors = false;
    });
  }

  void _showLocationDialog() {
    var db = MockDbService.to;
    String tempDiv = db.currentDivision.value;
    String tempDist = db.currentDistrict.value;
    String tempUpazila = db.currentUpazila.value;
    String tempArea = db.currentArea.value;

    // Sanitize initial values
    if (!db.divisions.contains(tempDiv)) {
      tempDiv = db.divisions.isNotEmpty ? db.divisions.first : 'Dhaka';
    }
    List<String> initialDistricts = db.getDistrictsFor(tempDiv);
    if (!initialDistricts.contains(tempDist)) {
      tempDist = initialDistricts.isNotEmpty ? initialDistricts.first : 'Dhaka';
    }
    List<String> initialUpazilas = db.getUpazilasFor(tempDist);
    if (!initialUpazilas.contains(tempUpazila)) {
      tempUpazila = initialUpazilas.isNotEmpty ? initialUpazilas.first : 'Sadar';
    }
    List<String> initialAreas = db.getAreasFor(tempUpazila);
    if (!initialAreas.contains(tempArea)) {
      tempArea = initialAreas.isNotEmpty ? initialAreas.first : 'Local Area';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<String> divList = db.divisions.toSet().toList();
            if (!divList.contains(tempDiv) && divList.isNotEmpty) {
              tempDiv = divList.first;
            }

            List<String> distList = db.getDistrictsFor(tempDiv).toSet().toList();
            if (!distList.contains(tempDist) && distList.isNotEmpty) {
              tempDist = distList.first;
            }

            List<String> upazilaList = db.getUpazilasFor(tempDist).toSet().toList();
            if (!upazilaList.contains(tempUpazila) && upazilaList.isNotEmpty) {
              tempUpazila = upazilaList.first;
            }

            List<String> areaList = db.getAreasFor(tempUpazila).toSet().toList();
            if (!areaList.contains(tempArea) && areaList.isNotEmpty) {
              tempArea = areaList.first;
            }

            return AlertDialog(
              title: const Text("Select Area"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Division dropdown
                    if (divList.isNotEmpty)
                      DropdownButtonFormField<String>(
                        key: ValueKey('div_$tempDiv'),
                        value: tempDiv,
                        decoration: const InputDecoration(labelText: "Division"),
                        items: divList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              tempDiv = val;
                              var newDists = db.getDistrictsFor(val);
                              tempDist = newDists.isNotEmpty ? newDists.first : '';
                              var newUpazilas = db.getUpazilasFor(tempDist);
                              tempUpazila = newUpazilas.isNotEmpty ? newUpazilas.first : '';
                              var newAreas = db.getAreasFor(tempUpazila);
                              tempArea = newAreas.isNotEmpty ? newAreas.first : 'Local Area';
                            });
                          }
                        },
                      ),
                    SizedBox(height: 12.h),

                    // District dropdown
                    if (distList.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        key: ValueKey('dist_${tempDiv}_$tempDist'),
                        value: tempDist,
                        decoration: const InputDecoration(labelText: "District"),
                        items: distList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              tempDist = val;
                              var newUpazilas = db.getUpazilasFor(val);
                              tempUpazila = newUpazilas.isNotEmpty ? newUpazilas.first : '';
                              var newAreas = db.getAreasFor(tempUpazila);
                              tempArea = newAreas.isNotEmpty ? newAreas.first : 'Local Area';
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // Upazila dropdown
                    if (upazilaList.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        key: ValueKey('upazila_${tempDist}_$tempUpazila'),
                        value: tempUpazila,
                        decoration: const InputDecoration(labelText: "Upazila"),
                        items: upazilaList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              tempUpazila = val;
                              var newAreas = db.getAreasFor(val);
                              tempArea = newAreas.isNotEmpty ? newAreas.first : 'Local Area';
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // Area dropdown
                    if (areaList.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        key: ValueKey('area_${tempUpazila}_$tempArea'),
                        value: tempArea,
                        decoration: const InputDecoration(labelText: "Area / Village"),
                        items: areaList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              tempArea = val;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    db.currentDivision.value = tempDiv;
                    db.currentDistrict.value = tempDist;
                    db.currentUpazila.value = tempUpazila;
                    db.currentArea.value = tempArea;
                    Get.back();
                    _fetchNearbyVendors();
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showLocationDialog,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF2563EB)),
                        SizedBox(width: 6.w),
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  db.currentArea.value,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  "${db.currentUpazila.value}, ${db.currentDistrict.value}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF6E6E86),
                                  ),
                                ),
                              ],
                            )),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF6E6E86)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0F172A)),
                    onPressed: () {
                      Get.to(() => const CustomerNotificationsScreen());
                    },
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Welcome text
              Text(
                "Find local items in your area",
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: 16.h),

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search for products...",
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF6E6E86)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          Get.to(() => ProductSearchScreen(initialQuery: val.trim()));
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () {
                      if (_searchController.text.trim().isNotEmpty) {
                        Get.to(() => ProductSearchScreen(initialQuery: _searchController.text.trim()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Categories Grid
              Text(
                "Quick Categories",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: 12.h),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                mainAxisSpacing: 12.r,
                crossAxisSpacing: 12.r,
                children: [
                  _buildCategoryCard("Electronics", Icons.devices, const Color(0xFF2563EB)),
                  _buildCategoryCard("Grocery", Icons.shopping_basket, const Color(0xFF0EA5E9)),
                  _buildCategoryCard("Medicine", Icons.medical_services, const Color(0xFF16A34A)),
                  _buildCategoryCard("Hardware", Icons.construction, const Color(0xFFF59E0B)),
                  _buildCategoryCard("Clothing", Icons.checkroom, const Color(0xFFE040FB)),
                  _buildCategoryCard("Others", Icons.grid_view, const Color(0xFF6E6E86)),
                ],
              ),
              SizedBox(height: 28.h),

              // Nearby Vendors
              Text(
                "Nearby Vendors in your Area",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: 12.h),

              _isLoadingVendors
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : (_apiVendors.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _apiVendors.length,
                          itemBuilder: (context, idx) {
                            var vendorItem = _apiVendors[idx];
                            var vendorMap = vendorItem.toJson();
                            return _buildVendorCard(vendorMap);
                          },
                        )
                      : Obx(() {
                          var nearby = db.vendors.where((v) => v['area'] == db.currentArea.value).toList();

                          if (nearby.isEmpty) {
                            return Container(
                              padding: EdgeInsets.all(24.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  const Icon(Icons.storefront, size: 48, color: Color(0xFF6E6E86)),
                                  SizedBox(height: 8.h),
                                  const Text("No vendors registered in your area yet.", style: TextStyle(color: Color(0xFF6E6E86))),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: nearby.length,
                            itemBuilder: (context, idx) {
                              var vendor = nearby[idx];
                              return _buildVendorCard(vendor);
                            },
                          );
                        })),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
            child: const Icon(Icons.store, color: Color(0xFF2563EB)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor['shopName'] ?? 'Store',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                Text(
                  "${vendor['name']} • ${vendor['category']}",
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF6E6E86)),
                    SizedBox(width: 2.w),
                    Text(
                      vendor['area'] ?? 'Local',
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6E6E86)),
                    ),
                    SizedBox(width: 12.w),
                    const Icon(Icons.directions_walk, size: 12, color: Color(0xFF16A34A)),
                    SizedBox(width: 2.w),
                    Text(
                      "${vendor['distanceKm'] ?? 1.2} km",
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.to(() => VendorProductScreen(vendor: vendor));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              elevation: 0,
            ),
            child: Text("Products", style: TextStyle(fontSize: 12.sp, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductSearchScreen(initialCategory: label));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple notifications container for customer requests.
class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: Color(0xFF6E6E86)),
            SizedBox(height: 12.h),
            const Text("No new notifications.", style: TextStyle(color: Color(0xFF6E6E86))),
          ],
        ),
      ),
    );
  }
}
