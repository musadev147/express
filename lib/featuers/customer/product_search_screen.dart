import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  void _autoCallVendorForQuery(String query) {
    var db = MockDbService.to;
    String q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    // Find products matching query in name or tags list
    var matchingProds = db.products.where((p) {
      List<dynamic> tagsList = p['tags'] ?? [];
      return p['name'].toString().toLowerCase().contains(q) ||
          tagsList.any((tag) => tag.toString().toLowerCase().contains(q));
    }).toList();

    if (matchingProds.isNotEmpty) {
      // Find a vendor in the current area selling one of these products
      for (var prod in matchingProds) {
        var matchingVendors = db.vendors.where((v) {
          return v['area'] == db.currentArea.value && v['phone'] == prod['vendorPhone'];
        }).toList();

        if (matchingVendors.isNotEmpty) {
          var vendor = matchingVendors.first;
          // Auto-trigger call
          db.startCall(
            receiverPhone: vendor['phone'],
            receiverName: vendor['name'],
            receiverShopName: vendor['shopName'],
            receiverArea: vendor['area'],
            productName: prod['name'],
          );
          Fluttertoast.showToast(msg: "Auto-calling ${vendor['shopName']} for ${prod['name']}...");
          return;
        }
      }
    }

    Fluttertoast.showToast(msg: "No local vendors found matching tags for '$query'");
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      // Trigger request recording
      Future.delayed(Duration.zero, () {
        db.addSearchRequest(widget.initialQuery!, db.currentArea.value);
      });
      // Auto call vendor
      Future.delayed(const Duration(milliseconds: 500), () {
        _autoCallVendorForQuery(widget.initialQuery!);
      });
    }
    if (widget.initialCategory != null) {
      _selectedCategory.value = widget.initialCategory!;
    }
  }

  MockDbService get db => MockDbService.to;

  void _callVendorForTag(String tag) {
    var db = MockDbService.to;
    String targetTag = tag.trim().toLowerCase();
    String area = db.currentArea.value;

    // Find products matching this tag
    var matchingProds = db.products.where((p) {
      List<dynamic> tagsList = p['tags'] ?? [];
      return tagsList.any((t) => t.toString().toLowerCase() == targetTag);
    }).toList();

    if (matchingProds.isNotEmpty) {
      for (var prod in matchingProds) {
        var matchingVendors = db.vendors.where((v) {
          return v['area'] == area && v['phone'] == prod['vendorPhone'];
        }).toList();

        if (matchingVendors.isNotEmpty) {
          var vendor = matchingVendors.first;
          db.startCall(
            receiverPhone: vendor['phone'],
            receiverName: vendor['name'],
            receiverShopName: vendor['shopName'],
            receiverArea: vendor['area'],
            productName: prod['name'],
          );
          Fluttertoast.showToast(msg: "Calling ${vendor['shopName']} for tag: $tag...");
          return;
        }
      }
    }
    Fluttertoast.showToast(msg: "No local vendors found for tag '$tag'");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Product Tag Search", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
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
                        hintText: "🔍 Search product tag...",
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
                            _autoCallVendorForQuery(val);
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
                          _autoCallVendorForQuery(val);
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

            // Search results list showing only tags
            Expanded(
              child: Obx(() {
                String query = _searchController.text.trim().toLowerCase();
                String category = _selectedCategory.value;
                String area = db.currentArea.value;

                // Match globally registered product names, tags, and sub-tags
                var matchingProducts = db.products.where((p) {
                  List<dynamic> tagsList = p['tags'] ?? [];
                  List<dynamic> subTagsList = p['subTags'] ?? [];
                  bool matchesQuery = query.isEmpty || 
                      p['name'].toString().toLowerCase().contains(query) ||
                      tagsList.any((tag) => tag.toString().toLowerCase().contains(query)) ||
                      subTagsList.any((sub) => sub.toString().toLowerCase().contains(query));
                  bool matchesCat = category == 'All' || p['category'].toString().toLowerCase() == category.toLowerCase();
                  return matchesQuery && matchesCat;
                }).toList();

                // Extract unique tags and sub-tags matching query
                var allTags = <String>{};
                for (var p in matchingProducts) {
                  List<dynamic> tagsList = p['tags'] ?? [];
                  List<dynamic> subTagsList = p['subTags'] ?? [];
                  for (var t in tagsList) {
                    String tagStr = t.toString().trim();
                    if (tagStr.isNotEmpty && (query.isEmpty || tagStr.toLowerCase().contains(query))) {
                      allTags.add(tagStr);
                    }
                  }
                  for (var s in subTagsList) {
                    String subStr = s.toString().trim();
                    if (subStr.isNotEmpty && (query.isEmpty || subStr.toLowerCase().contains(query))) {
                      allTags.add(subStr);
                    }
                  }
                }
                var matchingTags = allTags.toList();

                if (matchingTags.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.tag, size: 64, color: Color(0xFF6E6E86)),
                        SizedBox(height: 12.h),
                        const Text("No tags found.", style: TextStyle(color: Color(0xFF6E6E86), fontWeight: FontWeight.bold)),
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
                  itemCount: matchingTags.length,
                  itemBuilder: (context, idx) {
                    var tag = matchingTags[idx];

                    // Find vendors selling products with this tag or sub-tag in target area
                    var vendorsWithTag = <Map<String, dynamic>>[];
                    var prodsWithTag = db.products.where((p) {
                      List<dynamic> tagsList = p['tags'] ?? [];
                      List<dynamic> subTagsList = p['subTags'] ?? [];
                      return tagsList.any((t) => t.toString().toLowerCase() == tag.toLowerCase()) ||
                             subTagsList.any((s) => s.toString().toLowerCase() == tag.toLowerCase());
                    }).toList();
                    
                    for (var prod in prodsWithTag) {
                      var matchingVendors = db.vendors.where((v) {
                        return v['area'] == area && v['phone'] == prod['vendorPhone'];
                      }).toList();
                      vendorsWithTag.addAll(matchingVendors);
                    }
                    var seen = <String>{};
                    vendorsWithTag.retainWhere((v) => seen.add(v['phone']));

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
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.tag, size: 18, color: Color(0xFF2563EB)),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        tag.toUpperCase(),
                                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              ElevatedButton.icon(
                                onPressed: () => _callVendorForTag(tag),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                ),
                                icon: const Icon(Icons.phone, size: 14),
                                label: const Text("Call"),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "Available Shops: ${vendorsWithTag.length} in $area",
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
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
