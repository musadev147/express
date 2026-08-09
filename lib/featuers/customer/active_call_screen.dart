import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../helpers/mock_db_service.dart';

class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({super.key});

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (MockDbService.to.activeCall.isNotEmpty && MockDbService.to.activeCall['status'] == 'active') {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDbService.to;

    return Obx(() {
      if (db.activeCall.isEmpty) {
        return const SizedBox.shrink();
      }

      final call = db.activeCall;
      final isVendor = db.currentRole.value == 'vendor';
      final status = call['status'] ?? 'dialing';
      final isDialing = status == 'dialing';
      
      final String displayName = isVendor 
          ? (call['callerRole'] == 'customer' ? call['callerName'] : call['receiverName'])
          : (call['callerRole'] == 'vendor' ? call['callerName'] : call['receiverShopName']);
          
      final String displaySubtitle = isVendor 
          ? "Customer • ${call['callerRole'] == 'customer' ? call['callerPhone'] : call['receiverPhone']}"
          : "Vendor • ${call['callerRole'] == 'vendor' ? call['callerPhone'] : call['receiverPhone']}";

      final String productName = call['productName'] ?? '';

      return Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Caller/Receiver Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isDialing ? Colors.amber.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDialing ? Icons.ring_volume : Icons.phone_in_talk,
                            color: isDialing ? Colors.amber : Colors.green,
                            size: 14.r,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            isDialing ? "DIALING..." : "ACTIVE CALL",
                            style: TextStyle(
                              color: isDialing ? Colors.amber : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (!isDialing)
                      Text(
                        _formatDuration(_secondsElapsed),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // Animated Profile & Connection State
              SizedBox(height: 10.h),
              Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.all(24.r * _pulseController.value),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDialing ? Colors.amber : Colors.blue).withOpacity(0.1 * (1 - _pulseController.value)),
                          ),
                          child: CircleAvatar(
                            radius: 42.r,
                            backgroundColor: isVendor ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                            child: Icon(
                              isVendor ? Icons.person : Icons.store,
                              size: 40.r,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      displayName,
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      displaySubtitle,
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                    ),
                    if (productName.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        "Interested Product: $productName",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF38BDF8),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: const Divider(color: Color(0xFF334155)),
              ),

              // Main Active Section (Varies by Role)
              Expanded(
                child: isDialing
                    ? _buildDialingView()
                    : (isVendor ? _buildVendorWorksheet(db) : _buildCustomerInvoiceProgress(db)),
              ),

              // Bottom Hang up button
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        db.endCall();
                        Fluttertoast.showToast(msg: "Call disconnected");
                      },
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDialingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.amber),
          SizedBox(height: 16.h),
          const Text(
            "Waiting for response...",
            style: TextStyle(color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // CUSTOMER VIEW: Watch Invoice being generated live
  Widget _buildCustomerInvoiceProgress(MockDbService db) {
    final call = db.activeCall;
    final generatedInvoice = call['invoiceGenerated'];
    final List<dynamic> items = call['items'] ?? [];

    if (generatedInvoice != null) {
      // Invoice completed
      final inv = Map<String, dynamic>.from(generatedInvoice);
      return Padding(
        padding: EdgeInsets.all(20.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                  SizedBox(width: 8.w),
                  Text(
                    "Invoice Received!",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                ],
              ),
              const Divider(),
              Text("Invoice ID: ${inv['id']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
              Text("Shop: ${inv['vendorShopName']}", style: TextStyle(color: Colors.grey[700], fontSize: 12.sp)),
              SizedBox(height: 8.h),
              Expanded(
                child: ListView.builder(
                  itemCount: (inv['items'] as List).length,
                  itemBuilder: (context, idx) {
                    var item = inv['items'][idx];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${item['name']} x${item['qty']}", style: TextStyle(fontSize: 13.sp, color: Colors.black87)),
                          Text("৳${item['price'] * item['qty']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Amount:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  Text("৳${inv['total']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: const Color(0xFF2563EB))),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Invoice still in progress
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(
                width: 14.r,
                height: 14.r,
                child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)),
              ),
              SizedBox(width: 10.w),
              Text(
                "Seller is building your invoice...",
                style: TextStyle(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            "Draft Invoice Items",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      "No items added yet.",
                      style: TextStyle(color: const Color(0xFF64748B), fontSize: 12.sp),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, idx) {
                      final item = items[idx];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? 'Product',
                                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "৳${item['price']} x ${item['qty']}",
                                  style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 11.sp),
                                ),
                              ],
                            ),
                            Text(
                              "৳${(item['price'] * item['qty']).toStringAsFixed(0)}",
                              style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // VENDOR VIEW: Add items and generate invoice
  Widget _buildVendorWorksheet(MockDbService db) {
    final phone = db.currentUser['phone'];
    final myProducts = db.products.where((p) => p['vendorPhone'] == phone && p['isAvailable'] == true).toList();
    final call = db.activeCall;
    final List<dynamic> items = call['items'] ?? [];
    final generatedInvoice = call['invoiceGenerated'];

    if (generatedInvoice != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
            SizedBox(height: 12.h),
            Text(
              "Invoice sent successfully!",
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              "Invoice ID: ${generatedInvoice['id']}",
              style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12.sp),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Call Invoice Cart (Top Section)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Text(
            "Current Invoice Items (${items.length})",
            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          flex: 2,
          child: items.isEmpty
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Invoice is empty. Select products below to add.",
                    style: TextStyle(color: const Color(0xFF64748B), fontSize: 12.sp),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: items.length,
                  itemBuilder: (context, idx) {
                    final item = items[idx];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                                Text("৳${item['price']}", style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 11.sp)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF94A3B8), size: 20),
                                onPressed: () => db.updateCallCartQty(item['id'], item['qty'] - 1),
                              ),
                              Text("${item['qty']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981), size: 20),
                                onPressed: () => db.updateCallCartQty(item['id'], item['qty'] + 1),
                              ),
                            ],
                          ),
                          Text(
                            "৳${item['price'] * item['qty']}",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Action generate button
        if (items.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  db.generateCallInvoice();
                  Fluttertoast.showToast(msg: "Invoice generated and sent to customer!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                icon: const Icon(Icons.send),
                label: const Text("Generate & Send Invoice"),
              ),
            ),
          ),

        const Divider(color: Color(0xFF334155)),

        // Product Catalog Section (Bottom Section)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
          child: Text(
            "Your Product Catalog",
            style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          flex: 3,
          child: myProducts.isEmpty
              ? Center(
                  child: Text(
                    "No products available. Please add products from dashboard first.",
                    style: TextStyle(color: const Color(0xFF64748B), fontSize: 12.sp),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: myProducts.length,
                  itemBuilder: (context, idx) {
                    final p = myProducts[idx];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['name'], style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                Text("৳${p['price']} • Stock: ${p['stock']}", style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 11.sp)),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              db.addCallCartItem(p);
                              Fluttertoast.showToast(msg: "Added ${p['name']}");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add, size: 12),
                            label: Text("Add", style: TextStyle(fontSize: 11.sp)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
