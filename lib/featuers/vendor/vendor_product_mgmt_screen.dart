import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';

class VendorProductMgmtScreen extends StatefulWidget {
  const VendorProductMgmtScreen({super.key});

  @override
  State<VendorProductMgmtScreen> createState() => _VendorProductMgmtScreenState();
}

class _VendorProductMgmtScreenState extends State<VendorProductMgmtScreen> {
  final _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  void _showAddEditProductDialog([Map<String, dynamic>? existingProduct]) {
    var db = MockDbService.to;
    bool isEditing = existingProduct != null;

    final nameController = TextEditingController(text: isEditing ? existingProduct['name'] : '');
    final priceController = TextEditingController(text: isEditing ? existingProduct['price'].toString() : '');
    final stockController = TextEditingController(text: isEditing ? existingProduct['stock'].toString() : '');
    final unitController = TextEditingController(text: isEditing ? existingProduct['unit'] : 'pcs');
    final descController = TextEditingController(text: isEditing ? existingProduct['description'] : '');

    String category = isEditing ? existingProduct['category'] : 'Electronics';
    bool isAvailable = isEditing ? (existingProduct['isAvailable'] ?? true) : true;

    final categories = ['Electronics', 'Grocery', 'Medicine', 'Hardware', 'Clothing', 'Others'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      isEditing ? "Edit Product" : "Add Product",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Product Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => category = val);
                        }
                      },
                    ),
                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Price (৳)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Stock Qty",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: unitController,
                            decoration: InputDecoration(
                              labelText: "Unit (e.g. pcs, kg, strip)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Row(
                          children: [
                            const Text("Available", style: TextStyle(fontWeight: FontWeight.w600)),
                            Switch(
                              value: isAvailable,
                              activeColor: const Color(0xFF16A34A),
                              onChanged: (val) {
                                setModalState(() => isAvailable = val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty || priceController.text.isEmpty || stockController.text.isEmpty) {
                          Fluttertoast.showToast(msg: "Please fill all required fields");
                          return;
                        }

                        double? price = double.tryParse(priceController.text);
                        int? stock = int.tryParse(stockController.text);

                        if (price == null || stock == null) {
                          Fluttertoast.showToast(msg: "Invalid price or stock quantity");
                          return;
                        }

                        db.saveProduct({
                          'id': isEditing ? existingProduct['id'] : 'p_${DateTime.now().millisecondsSinceEpoch}',
                          'name': nameController.text.trim(),
                          'category': category,
                          'price': price,
                          'stock': stock,
                          'unit': unitController.text.trim(),
                          'description': descController.text.trim(),
                          'isAvailable': isAvailable,
                          'vendorPhone': db.currentUser['phone']
                        });

                        Fluttertoast.showToast(msg: isEditing ? "Product updated!" : "Product saved!");
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(isEditing ? "Update Product" : "Save Product", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
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
      appBar: AppBar(
        title: const Text("Product Management", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Add Button
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (val) {
                        _searchQuery.value = val.trim().toLowerCase();
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () => _showAddEditProductDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: EdgeInsets.all(16.r),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            // Products list
            Expanded(
              child: Obx(() {
                var phone = db.currentUser['phone'];
                var myProducts = db.products.where((p) {
                  bool isMine = p['vendorPhone'] == phone;
                  bool matchesQuery = _searchQuery.value.isEmpty || p['name'].toString().toLowerCase().contains(_searchQuery.value);
                  return isMine && matchesQuery;
                }).toList();

                if (myProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF6E6E86)),
                        SizedBox(height: 12.h),
                        const Text("No products found.", style: TextStyle(color: Color(0xFF6E6E86))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: myProducts.length,
                  itemBuilder: (context, index) {
                    var prod = myProducts[index];
                    bool isAvailable = prod['isAvailable'] ?? false;

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
                              Text(
                                prod['name'] ?? 'Product Name',
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              ),
                              Text(
                                "৳${prod['price']}",
                                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Category: ${prod['category']} • Stock: ${prod['stock']} ${prod['unit']}",
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: isAvailable ? const Color(0xFF16A34A).withOpacity(0.1) : const Color(0xFFDC2626).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              isAvailable ? "Available" : "Out of Stock",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showAddEditProductDialog(prod),
                                icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
                                label: const Text("Edit", style: TextStyle(color: Color(0xFF2563EB))),
                              ),
                              SizedBox(width: 12.w),
                              TextButton.icon(
                                onPressed: () {
                                  db.deleteProduct(prod['id']);
                                  Fluttertoast.showToast(msg: "Product deleted");
                                },
                                icon: const Icon(Icons.delete, color: Color(0xFFDC2626)),
                                label: const Text("Delete", style: TextStyle(color: Color(0xFFDC2626))),
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
