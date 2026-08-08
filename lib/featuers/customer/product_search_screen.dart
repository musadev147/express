import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';
import 'vendor_list_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;

  const ProductSearchScreen({super.key, this.initialQuery, this.initialCategory});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final _searchController = TextEditingController();
  final RxString _selectedCategory = 'All'.obs;
  final List<String> categories = ['All', 'Electronics', 'Grocery', 'Medicine', 'Hardware', 'Clothing', 'Others'];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      // Trigger request recording
      Future.delayed(Duration.zero, () {
        MockDbService.to.addSearchRequest(widget.initialQuery!, MockDbService.to.currentArea.value);
      });
    }
    if (widget.initialCategory != null) {
      _selectedCategory.value = widget.initialCategory!;
    }
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Product Search", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "🔍 Search product...",
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF6E6E86)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSubmitted: (val) {
                        setState(() {
                          if (val.isNotEmpty) {
                            db.addSearchRequest(val, db.currentArea.value);
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        String val = _searchController.text.trim();
                        if (val.isNotEmpty) {
                          db.addSearchRequest(val, db.currentArea.value);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: const Text("Search"),
                  ),
                ],
              ),
            ),

            // Horizontal Categories selector
            SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    bool isSelected = _selectedCategory.value == categories[index];
                    return GestureDetector(
                      onTap: () {
                        _selectedCategory.value = categories[index];
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            SizedBox(height: 16.h),

            // Search results list
            Expanded(
              child: Obx(() {
                String query = _searchController.text.trim().toLowerCase();
                String category = _selectedCategory.value;
                String area = db.currentArea.value;

                // Match globally registered product names
                var matchingProducts = db.products.where((p) {
                  bool matchesQuery = query.isEmpty || p['name'].toString().toLowerCase().contains(query);
                  bool matchesCat = category == 'All' || p['category'].toString().toLowerCase() == category.toLowerCase();
                  return matchesQuery && matchesCat;
                }).toList();

                if (matchingProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Color(0xFF6E6E86)),
                        SizedBox(height: 12.h),
                        const Text("No products found.", style: TextStyle(color: Color(0xFF6E6E86), fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text(
                          "We notified vendors in $area about your request!",
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: matchingProducts.length,
                  itemBuilder: (context, idx) {
                    var prod = matchingProducts[idx];

                    // Find vendors in target area selling this product
                    var matchingVendors = db.vendors.where((v) {
                      return v['area'] == area && v['phone'] == prod['vendorPhone'];
                    }).toList();

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prod['name'] ?? 'Product',
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              ),
                              Text(
                                "৳${prod['price']}",
                                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Category: ${prod['category']}",
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Available Vendors: ${matchingVendors.length}",
                                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    "Area: $area",
                                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.to(() => VendorListScreen(
                                        product: prod,
                                        vendors: matchingVendors,
                                      ));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  elevation: 0,
                                ),
                                child: const Text("Search Vendors"),
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
          ],
        ),
      ),
    );
  }
}
