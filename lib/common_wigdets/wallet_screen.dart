import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../helpers/mock_db_service.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _showWithdrawDialog(BuildContext context, double currentBalance) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text("Withdraw Funds"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter amount to transfer to your linked bank account / bKash:"),
              SizedBox(height: 12.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount (৳)",
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
                double? amt = double.tryParse(amountController.text);
                if (amt == null || amt <= 0) {
                  Fluttertoast.showToast(msg: "Please enter a valid amount");
                  return;
                }
                if (amt > currentBalance) {
                  Fluttertoast.showToast(msg: "Insufficient balance");
                  return;
                }
                Fluttertoast.showToast(msg: "Withdrawal of ৳${amt.toStringAsFixed(0)} initiated successfully!");
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text("Withdraw"),
            ),
          ],
        );
      },
    );
  }

  void _showTopUpDialog(BuildContext context) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text("Top Up Wallet"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add money to your wallet instantly via Card / Mobile Banking:"),
              SizedBox(height: 12.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount (৳)",
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
                double? amt = double.tryParse(amountController.text);
                if (amt == null || amt <= 0) {
                  Fluttertoast.showToast(msg: "Please enter a valid amount");
                  return;
                }
                Fluttertoast.showToast(msg: "Top up of ৳${amt.toStringAsFixed(0)} successful!");
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text("Top Up"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDbService.to;
    final isVendor = db.currentRole.value == 'vendor';
    final Color primaryColor = isVendor ? const Color(0xFF16A34A) : const Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("My Wallet", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Balance Card
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isVendor 
                        ? [const Color(0xFF16A34A), const Color(0xFF10B981)]
                        : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVendor ? "Total Seller Earnings" : "Available Balance",
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      isVendor ? "৳12,450.00" : "৳3,720.00",
                      style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showTopUpDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text("Top Up", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        if (isVendor) ...[
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showWithdrawDialog(context, 12450.0),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              icon: const Icon(Icons.account_balance_wallet, size: 18),
                              label: const Text("Withdraw", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // Recent Transactions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Transactions",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => AllTransactionsScreen(isVendor: isVendor));
                    },
                    child: Text("View All", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Mock Transactions List
              _buildTransactionItem(
                title: isVendor ? "Received from Napa Extra sale" : "Paid to Rahman Electronics",
                subtitle: "Today, 10:45 AM",
                amount: isVendor ? "+৳350.00" : "-৳1,200.00",
                isPositive: isVendor,
              ),
              _buildTransactionItem(
                title: isVendor ? "Received from Charger 25W sale" : "Paid to Faruk Grocery Store",
                subtitle: "Yesterday, 4:20 PM",
                amount: isVendor ? "+৳1,200.00" : "-৳450.00",
                isPositive: isVendor,
              ),
              _buildTransactionItem(
                title: isVendor ? "Withdrawal to bKash" : "Refund Credit",
                subtitle: "06 Aug 2026, 12:15 PM",
                amount: isVendor ? "-৳5,000.00" : "+৳250.00",
                isPositive: !isVendor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
    required bool isPositive,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
            child: Icon(
              isPositive ? Icons.call_received : Icons.call_made,
              color: isPositive ? Colors.green : Colors.red,
              size: 20.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                SizedBox(height: 2.h),
                Text(subtitle, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class AllTransactionsScreen extends StatelessWidget {
  final bool isVendor;
  const AllTransactionsScreen({super.key, required this.isVendor});

  @override
  Widget build(BuildContext context) {
    // Generate a larger mock list of transactions
    List<Map<String, dynamic>> mockList = [
      {"title": isVendor ? "Received from Napa Extra sale" : "Paid to Rahman Electronics", "subtitle": "Today, 10:45 AM", "amount": isVendor ? "+৳350.00" : "-৳1,200.00", "isPositive": isVendor},
      {"title": isVendor ? "Received from Charger 25W sale" : "Paid to Faruk Grocery Store", "subtitle": "Yesterday, 4:20 PM", "amount": isVendor ? "+৳1,200.00" : "-৳450.00", "isPositive": isVendor},
      {"title": isVendor ? "Withdrawal to bKash" : "Refund Credit", "subtitle": "06 Aug 2026, 12:15 PM", "amount": isVendor ? "-৳5,000.00" : "+৳250.00", "isPositive": !isVendor},
      {"title": isVendor ? "Received from USB Cable sale" : "Paid to Karim Pharmacy", "subtitle": "05 Aug 2026, 09:30 AM", "amount": isVendor ? "+৳180.00" : "-৳320.00", "isPositive": isVendor},
      {"title": isVendor ? "Received from Rice 5kg sale" : "Paid to Salim Dairy", "subtitle": "04 Aug 2026, 06:10 PM", "amount": isVendor ? "+৳400.00" : "-৳150.00", "isPositive": isVendor},
      {"title": isVendor ? "Withdrawal to Bank Account" : "Added Money via Visa Card", "subtitle": "03 Aug 2026, 10:00 AM", "amount": isVendor ? "-৳4,000.00" : "+৳1,500.00", "isPositive": !isVendor},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("All Transactions", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20.r),
        itemCount: mockList.length,
        itemBuilder: (context, idx) {
          var item = mockList[idx];
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.black.withOpacity(0.03)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (item['isPositive'] ? Colors.green : Colors.red).withOpacity(0.1),
                  child: Icon(
                    item['isPositive'] ? Icons.call_received : Icons.call_made,
                    color: item['isPositive'] ? Colors.green : Colors.red,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      SizedBox(height: 2.h),
                      Text(item['subtitle'], style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
                Text(
                  item['amount'],
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: item['isPositive'] ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
