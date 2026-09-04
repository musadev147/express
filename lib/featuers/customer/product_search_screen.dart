import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../helpers/mock_db_service.dart';
import '../../networks/api_acess.dart';
import '../../networks/model/product_model.dart';
import '../../networks/model/search_demand_model.dart';
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
  List<ProductResponse> _apiSearchResults = [];
  bool _isSearching = false;

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

  Future<void> _executeSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
    });

    // 1. Broadcast search demand
    try {
      createSearchDemandRx.createSearchDemand(
        SearchDemandCreateRequest(
          query: query.trim(),
          area: db.currentArea.value,
          upazila: db.currentUpazila.value,
          district: db.currentDistrict.value,
          division: db.currentDivision.value,
        ),
      );
    } catch (_) {}

    // 2. Fetch live search API
    try {
      var cat = _selectedCategory.value != 'All' ? _selectedCategory.value : null;
      var response = await searchProductsRx.searchProducts(
        query: query.trim(),
        area: db.currentArea.value,
        category: cat,
      );
      if (response.success && response.data != null) {
        setState(() {
          _apiSearchResults = response.data!;
          _isSearching = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      // Trigger request recording
      Future.delayed(Duration.zero, () {
        db.addSearchRequest(widget.initialQuery!, db.currentArea.value);
        _executeSearch(widget.initialQuery!);
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
                        if (val.isNotEmpty) {
                          db.addSearchRequest(val, db.currentArea.value);
                          _executeSearch(val);
                          _autoCallVendorForQuery(val);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      String val = _searchController.text.trim();
                      if (val.isNotEmpty) {
                        db.addSearchRequest(val, db.currentArea.value);
                        _executeSearch(val);
                        _autoCallVendorForQuery(val);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: const Text("Search", style: TextStyle(color: Colors.white)),
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
                        if (_searchController.text.isNotEmpty) {
                          _executeSearch(_searchController.text);
                        }
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

            // Search results
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : Obx(() {
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
                        for (var st in subTagsList) {
                          String subStr = st.toString().trim();
                          if (subStr.isNotEmpty && (query.isEmpty || subStr.toLowerCase().contains(query))) {
                            allTags.add(subStr);
                          }
                        }
                        if (p['name'].toString().toLowerCase().contains(query)) {
                          allTags.add(p['name'].toString());
                        }
                      }

                      // If also has API search results, add tags
                      for (var ap in _apiSearchResults) {
                        allTags.add(ap.name);
                        for (var t in ap.tags) {
                          allTags.add(t);
                        }
                      }

                      var tagList = allTags.toList();

                      if (tagList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Color(0xFF6E6E86)),
                              SizedBox(height: 12.h),
                              Text("No tags or products match '$query'", style: const TextStyle(color: Color(0xFF6E6E86))),
                              SizedBox(height: 12.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  "Broadcasted to local $area vendors!",
                                  style: TextStyle(color: const Color(0xFF2563EB), fontSize: 12.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: tagList.length,
                        itemBuilder: (context, idx) {
                          String tag = tagList[idx];
                          var localVendorsWithTag = db.vendors.where((v) {
                            return v['area'] == area &&
                                db.products.any((p) =>
                                    p['vendorPhone'] == v['phone'] &&
                                    ((p['tags'] != null && (p['tags'] as List).any((t) => t.toString().toLowerCase() == tag.toLowerCase())) ||
                                        (p['subTags'] != null && (p['subTags'] as List).any((st) => st.toString().toLowerCase() == tag.toLowerCase())) ||
                                        p['name'].toString().toLowerCase() == tag.toLowerCase()));
                          }).toList();

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.black.withOpacity(0.04)),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                                child: const Icon(Icons.sell_outlined, color: Color(0xFF2563EB), size: 20),
                              ),
                              title: Text(
                                tag,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: const Color(0xFF0F172A)),
                              ),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    localVendorsWithTag.isNotEmpty ? Icons.check_circle : Icons.info_outline,
                                    size: 13.sp,
                                    color: localVendorsWithTag.isNotEmpty ? const Color(0xFF16A34A) : const Color(0xFF6E6E86),
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      localVendorsWithTag.isNotEmpty
                                          ? "${localVendorsWithTag.length} store(s) in $area"
                                          : "0 stores in $area",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: localVendorsWithTag.isNotEmpty ? const Color(0xFF16A34A) : const Color(0xFF6E6E86),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                                    icon: const Icon(Icons.phone, color: Color(0xFF16A34A), size: 22),
                                    onPressed: () => _callVendorForTag(tag),
                                  ),
                                  SizedBox(width: 4.w),
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => VendorListScreen(productTag: tag));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                      elevation: 0,
                                    ),
                                    child: Text("Stores", style: TextStyle(fontSize: 11.sp, color: Colors.white)),
                                  ),
                                ],
                              ),
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
