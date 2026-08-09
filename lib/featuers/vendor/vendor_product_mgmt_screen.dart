import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';
import '../../helpers/gemini_service.dart';

class VendorProductMgmtScreen extends StatefulWidget {
  const VendorProductMgmtScreen({super.key});

  @override
  State<VendorProductMgmtScreen> createState() => _VendorProductMgmtScreenState();
}

class _VendorProductMgmtScreenState extends State<VendorProductMgmtScreen> {
  final _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  void _showAddTagDialog() {
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text("Add Parent Tag"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter product tag keyword (e.g. MEDICINE, MOBILE, GROCERY)"),
              SizedBox(height: 12.h),
              TextField(
                controller: tagController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: "Tag Name",
                  hintText: "e.g. MEDICINE",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                String val = tagController.text.trim().toUpperCase();
                if (val.isEmpty) {
                  Fluttertoast.showToast(msg: "Please enter a tag");
                  return;
                }
                var db = MockDbService.to;
                var phone = db.currentUser['phone'];

                // Check if tag already exists
                var myProducts = db.products.where((p) => p['vendorPhone'] == phone).toList();
                bool exists = myProducts.any((p) {
                  List<dynamic> tagsList = p['tags'] ?? [];
                  return tagsList.any((t) => t.toString().toUpperCase() == val);
                });

                if (exists) {
                  Fluttertoast.showToast(msg: "Tag '$val' already exists in your list");
                  return;
                }

                // Add as a mock tag-product with empty subTags list
                Map<String, dynamic> mockTagProduct = {
                  'id': 'PROD-${DateTime.now().millisecondsSinceEpoch}',
                  'name': val,
                  'vendorPhone': phone,
                  'tags': [val],
                  'subTags': <String>[],
                  'price': 0,
                  'category': 'Others',
                  'isAvailable': true,
                };
                db.saveProduct(mockTagProduct);

                Fluttertoast.showToast(msg: "Added tag '$val' successfully!");
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showAddSubTagDialog(Map<String, dynamic> product) {
    final subTagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text("Add Sub-Tag to ${product['name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter sub-tag item keyword under parent '${product['name']}' (e.g. NAPA, CHARGER, RICE)"),
              SizedBox(height: 12.h),
              TextField(
                controller: subTagController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: "Sub-Tag Name",
                  hintText: "e.g. NAPA",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                String val = subTagController.text.trim().toUpperCase();
                if (val.isEmpty) {
                  Fluttertoast.showToast(msg: "Please enter a sub-tag");
                  return;
                }
                var db = MockDbService.to;

                List<dynamic> subTagsList = List<dynamic>.from(product['subTags'] ?? []);
                if (subTagsList.any((t) => t.toString().toUpperCase() == val)) {
                  Fluttertoast.showToast(msg: "Sub-tag '$val' already exists");
                  return;
                }

                subTagsList.add(val);

                var updatedProduct = Map<String, dynamic>.from(product);
                updatedProduct['subTags'] = subTagsList;
                db.saveProduct(updatedProduct);

                Fluttertoast.showToast(msg: "Added sub-tag '$val' successfully!");
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSubTag(Map<String, dynamic> product, String subTag) {
    var db = MockDbService.to;
    List<dynamic> subTagsList = List<dynamic>.from(product['subTags'] ?? []);
    subTagsList.removeWhere((t) => t.toString().toUpperCase() == subTag.toUpperCase());

    var updatedProduct = Map<String, dynamic>.from(product);
    updatedProduct['subTags'] = subTagsList;
    db.saveProduct(updatedProduct);

    Fluttertoast.showToast(msg: "Removed sub-tag '$subTag'");
  }

  void _deleteTag(String prodId) {
    var db = MockDbService.to;
    db.deleteProduct(prodId);
    Fluttertoast.showToast(msg: "Parent tag and its sub-tags removed.");
  }

  void _suggestSubTagsWithAI(Map<String, dynamic> product) async {
    Fluttertoast.showToast(msg: "Gemini AI is generating recommendations...");
    var suggestions = await GeminiService.to.suggestSubTags(product['name']);
    
    if (suggestions.isEmpty) {
      Fluttertoast.showToast(msg: "No recommendations found.");
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.purple),
              SizedBox(width: 8.w),
              const Text("AI Suggestions"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Gemini recommended these sub-tags for '${product['name']}':"),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: suggestions.map((sub) {
                  return Chip(
                    label: Text(sub, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.purple)),
                    backgroundColor: Colors.purple.withOpacity(0.06),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                var db = MockDbService.to;
                List<dynamic> subTagsList = List<dynamic>.from(product['subTags'] ?? []);
                for (var s in suggestions) {
                  if (!subTagsList.any((t) => t.toString().toUpperCase() == s.toUpperCase())) {
                    subTagsList.add(s);
                  }
                }

                var updatedProduct = Map<String, dynamic>.from(product);
                updatedProduct['subTags'] = subTagsList;
                db.saveProduct(updatedProduct);

                Fluttertoast.showToast(msg: "Applied AI suggestions!");
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text("Apply Suggestions"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var db = MockDbService.to;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Manage Tags & Sub-Tags", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12.w),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF16A34A).withOpacity(0.08),
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF16A34A)),
                onPressed: _showAddTagDialog,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search tags or sub-tags...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6E6E86)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  onChanged: (val) => _searchQuery.value = val.trim().toLowerCase(),
                ),
              ),
            ),

            // Tags and Sub-Tags list
            Expanded(
              child: Obx(() {
                var phone = db.currentUser['phone'];
                var myProducts = db.products.where((p) => p['vendorPhone'] == phone).toList();

                // Filter by search query
                var q = _searchQuery.value;
                var filteredProducts = myProducts.where((p) {
                  String name = p['name'].toString().toLowerCase();
                  List<dynamic> subTagsList = p['subTags'] ?? [];
                  bool matchesSub = subTagsList.any((sub) => sub.toString().toLowerCase().contains(q));
                  return q.isEmpty || name.contains(q) || matchesSub;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.style_outlined, size: 64, color: Color(0xFF6E6E86)),
                        SizedBox(height: 12.h),
                        Text(
                          q.isEmpty ? "No tags added yet." : "No matching tags found.",
                          style: const TextStyle(color: Color(0xFF6E6E86)),
                        ),
                        SizedBox(height: 16.h),
                        if (q.isEmpty)
                          ElevatedButton.icon(
                            onPressed: _showAddTagDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text("Add First Tag"),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, idx) {
                    var prod = filteredProducts[idx];
                    String tagName = prod['name'] ?? '';
                    List<dynamic> subTags = prod['subTags'] ?? [];

                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: Colors.black.withOpacity(0.02)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Premium icon container
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16A34A).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: const Icon(Icons.style_outlined, color: Color(0xFF16A34A), size: 18),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    tagName.toUpperCase(),
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // AI Auto-Suggest Button
                                  IconButton(
                                    icon: const Icon(Icons.auto_awesome, color: Colors.purple, size: 24),
                                    onPressed: () => _suggestSubTagsWithAI(prod),
                                    tooltip: "AI Suggest Sub-Tags",
                                  ),
                                  SizedBox(width: 2.w),
                                  // Premium styled add action
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB), size: 26),
                                    onPressed: () => _showAddSubTagDialog(prod),
                                    tooltip: "Add Sub-Tag",
                                  ),
                                  SizedBox(width: 4.w),
                                  // Premium styled delete action
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 26),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Delete Parent Tag"),
                                          content: Text("Are you sure you want to remove '$tagName' and all its sub-tags?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _deleteTag(prod['id']);
                                                Get.back();
                                              },
                                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (subTags.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: subTags.map((sub) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A).withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.12)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.subdirectory_arrow_right, size: 12, color: Color(0xFF16A34A)),
                                      SizedBox(width: 6.w),
                                      Text(
                                        sub.toString().toUpperCase(),
                                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                      ),
                                      SizedBox(width: 8.w),
                                      GestureDetector(
                                        onTap: () => _deleteSubTag(prod, sub.toString()),
                                        child: const Icon(Icons.cancel, size: 14, color: Color(0xFFEF4444)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ] else ...[
                            SizedBox(height: 12.h),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            SizedBox(height: 10.h),
                            Text(
                              "No sub-tags added. Tap the blue '+' button to add items.",
                              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                            ),
                          ],
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
