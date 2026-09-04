import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../helpers/mock_db_service.dart';
import '../../networks/api_acess.dart';
import '../../networks/model/invoice_model.dart';
import 'invoice_details_screen.dart';

class CustomerInvoicesScreen extends StatefulWidget {
  const CustomerInvoicesScreen({super.key});

  @override
  State<CustomerInvoicesScreen> createState() => _CustomerInvoicesScreenState();
}

class _CustomerInvoicesScreenState extends State<CustomerInvoicesScreen> {
  List<InvoiceResponse> _apiInvoices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var res = await getInvoicesRx.fetchInvoices();
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          _apiInvoices = res.data!;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      DateTime dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(dt);
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
        title: const Text("My Invoices", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _apiInvoices.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: _apiInvoices.length,
                    itemBuilder: (context, index) {
                      var inv = _apiInvoices[index];
                      var invoiceMap = inv.toJson();

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inv.id,
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    "${inv.vendorShopName} • ${inv.vendorArea}",
                                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _formatDate(inv.dateTime),
                                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6E6E86)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "৳${inv.total.toStringAsFixed(0)}",
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                                ),
                                SizedBox(height: 6.h),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => InvoiceDetailsScreen(invoice: invoiceMap));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                                  ),
                                  child: Text("Details", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF2563EB))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Obx(() {
                    var customerInvoices = db.invoices.where((inv) {
                      return inv['customerPhone'] == db.currentUser['phone'];
                    }).toList();

                    if (customerInvoices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF6E6E86)),
                            SizedBox(height: 12.h),
                            const Text("No invoices generated yet.", style: TextStyle(color: Color(0xFF6E6E86))),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: customerInvoices.length,
                      itemBuilder: (context, index) {
                        var invoice = customerInvoices[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.black.withOpacity(0.04)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invoice['id'] ?? 'INV-00000',
                                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      "${invoice['vendorShopName'] ?? ''} • ${invoice['vendorArea'] ?? ''}",
                                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6E6E86)),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _formatDate(invoice['dateTime']),
                                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6E6E86)),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "৳${invoice['total'] ?? 0}",
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                                  ),
                                  SizedBox(height: 6.h),
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => InvoiceDetailsScreen(invoice: invoice));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                                    ),
                                    child: Text("Details", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF2563EB))),
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
