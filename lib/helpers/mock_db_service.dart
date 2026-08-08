import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MockDbService extends GetxController {
  static MockDbService get to => Get.find<MockDbService>();

  final _box = GetStorage();

  // Observable state
  final RxString currentRole = 'customer'.obs; // 'customer' or 'vendor'
  final RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;

  // Selected area for Customer
  final RxString currentArea = 'Kaliganj Bazar'.obs;
  final RxString currentUpazila = 'Kaliganj'.obs;
  final RxString currentDistrict = 'Gazipur'.obs;
  final RxString currentDivision = 'Dhaka'.obs;

  // Lists
  final RxList<Map<String, dynamic>> vendors = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> invoices = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> searchRequests = <Map<String, dynamic>>[].obs;

  // Cart for invoice generation
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  // Pre-configured list of Areas
  final List<String> divisions = ['Dhaka', 'Chittagong', 'Rajshahi', 'Sylhet'];
  final Map<String, List<String>> districts = {
    'Dhaka': ['Dhaka', 'Gazipur', 'Narayanganj'],
    'Chittagong': ['Chittagong', 'Cox\'s Bazar', 'Feni'],
    'Rajshahi': ['Rajshahi', 'Bogra', 'Pabna'],
    'Sylhet': ['Sylhet', 'Moulvibazar', 'Habiganj'],
  };
  final Map<String, List<String>> upazilas = {
    'Dhaka': ['Mirpur', 'Dhanmondi', 'Gulshan'],
    'Gazipur': ['Kaliganj', 'Sreepur', 'Gazipur Sadar'],
    'Narayanganj': ['Sadar', 'Rupganj', 'Araihazar'],
  };
  final Map<String, List<String>> areas = {
    'Kaliganj': ['Kaliganj Bazar', 'Tumulia', 'Nagari', 'Jangal'],
    'Sreepur': ['Maona', 'Sreepur Bazar', 'Telihati'],
    'Mirpur': ['Mirpur 1', 'Mirpur 10', 'Mirpur 12'],
    'Dhanmondi': ['Dhanmondi 32', 'Dhanmondi 15', 'Sobhanbagh'],
  };

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load vendors
    List<dynamic>? storedVendors = _box.read<List<dynamic>>('vendors');
    if (storedVendors != null && storedVendors.isNotEmpty) {
      vendors.assignAll(storedVendors.map((e) => Map<String, dynamic>.from(e)).toList());
    } else {
      // Seed default vendors
      vendors.assignAll([
        {
          'name': 'Abdur Rahman',
          'shopName': 'Rahman Electronics',
          'phone': '01711111111',
          'email': 'rahman@mail.com',
          'address': 'Kaliganj Bazar Road',
          'division': 'Dhaka',
          'district': 'Gazipur',
          'upazila': 'Kaliganj',
          'area': 'Kaliganj Bazar',
          'category': 'Electronics',
          'password': '123'
        },
        {
          'name': 'Faruk Hossain',
          'shopName': 'Faruk Grocery Store',
          'phone': '01722222222',
          'email': 'faruk@mail.com',
          'address': 'Maona Highway Chourasta',
          'division': 'Dhaka',
          'district': 'Gazipur',
          'upazila': 'Sreepur',
          'area': 'Maona',
          'category': 'Grocery',
          'password': '123'
        },
        {
          'name': 'Dr. Selim',
          'shopName': 'Selim Pharmacy',
          'phone': '01733333333',
          'email': 'selim@mail.com',
          'address': 'Tumulia Hospital Gate',
          'division': 'Dhaka',
          'district': 'Gazipur',
          'upazila': 'Kaliganj',
          'area': 'Tumulia',
          'category': 'Medicine',
          'password': '123'
        }
      ]);
      _saveVendors();
    }


    // Load products
    List<dynamic>? storedProducts = _box.read<List<dynamic>>('products');
    if (storedProducts != null && storedProducts.isNotEmpty) {
      products.assignAll(storedProducts.map((e) => Map<String, dynamic>.from(e)).toList());
    } else {

      // Seed default products
      products.assignAll([
        {
          'id': 'p1',
          'name': 'Samsung Charger 25W',
          'vendorPhone': '01711111111',
          'category': 'Electronics',
          'description': 'Original Samsung Fast Charging Adapter',
          'price': 1200.0,
          'stock': 15,
          'unit': 'pcs',
          'isAvailable': true
        },
        {
          'id': 'p2',
          'name': 'USB Type-C Cable',
          'vendorPhone': '01711111111',
          'category': 'Electronics',
          'description': 'Braided durable fast data sync cable',
          'price': 250.0,
          'stock': 40,
          'unit': 'pcs',
          'isAvailable': true
        },
        {
          'id': 'p3',
          'name': 'Miniket Rice Premium',
          'vendorPhone': '01722222222',
          'category': 'Grocery',
          'description': '50kg pack refined white rice',
          'price': 3400.0,
          'stock': 100,
          'unit': 'bag',
          'isAvailable': true
        },
        {
          'id': 'p4',
          'name': 'Napa Extra Tab',
          'vendorPhone': '01733333333',
          'category': 'Medicine',
          'description': 'Paracetamol 500mg + Caffeine 65mg',
          'price': 30.0,
          'stock': 500,
          'unit': 'strip',
          'isAvailable': true
        }
      ]);
      _saveProducts();
    }

    // Load invoices
    List<dynamic>? storedInvoices = _box.read<List<dynamic>>('invoices');
    if (storedInvoices != null) {
      invoices.assignAll(storedInvoices.map((e) => Map<String, dynamic>.from(e)).toList());
    }

    // Load search requests
    List<dynamic>? storedRequests = _box.read<List<dynamic>>('searchRequests');
    if (storedRequests != null) {
      searchRequests.assignAll(storedRequests.map((e) => Map<String, dynamic>.from(e)).toList());
    }

    // Current user state
    var user = _box.read('currentUser');
    if (user != null) {
      currentUser.value = Map<String, dynamic>.from(user);
      currentRole.value = _box.read<String>('currentRole') ?? 'customer';
    }
  }

  void _saveVendors() => _box.write('vendors', vendors.toList());
  void _saveProducts() => _box.write('products', products.toList());
  void _saveInvoices() => _box.write('invoices', invoices.toList());
  void _saveSearchRequests() => _box.write('searchRequests', searchRequests.toList());

  // Sign In
  bool signIn(String phone, String password, String role) {
    if (role == 'customer') {
      currentUser.value = {
        'name': 'Regular Customer',
        'phone': phone,
        'role': 'customer',
      };
      currentRole.value = 'customer';
      _box.write('currentUser', currentUser.value);
      _box.write('currentRole', 'customer');
      return true;
    } else {
      var vendor = vendors.firstWhere(
        (v) => v['phone'] == phone,
        orElse: () => <String, dynamic>{},
      );
      if (vendor.isEmpty) {
        // Auto-create a mock vendor for this new number on the fly
        vendor = {
          'name': 'Demo Vendor Owner',
          'shopName': 'Local Express Shop (${phone.substring(phone.length - 4)})',
          'phone': phone,
          'email': 'vendor_${phone}@express.com',
          'address': 'Main Bazar Highway Road',
          'division': 'Dhaka',
          'district': 'Gazipur',
          'upazila': 'Kaliganj',
          'area': 'Kaliganj Bazar',
          'category': 'Electronics',
          'password': password
        };
        vendors.add(vendor);
        _saveVendors();
      }
      currentUser.value = vendor;
      currentRole.value = 'vendor';
      _box.write('currentUser', currentUser.value);
      _box.write('currentRole', 'vendor');
      return true;
    }
  }


  // Register Customer
  void registerCustomer(String phone, String name) {
    currentUser.value = {
      'name': name,
      'phone': phone,
      'role': 'customer',
    };
    currentRole.value = 'customer';
    _box.write('currentUser', currentUser.value);
    _box.write('currentRole', 'customer');
  }

  // Register Vendor
  bool registerVendor(Map<String, dynamic> vendorData) {
    if (vendors.any((v) => v['phone'] == vendorData['phone'])) {
      return false; // already registered
    }
    vendors.add(vendorData);
    _saveVendors();
    currentUser.value = vendorData;
    currentRole.value = 'vendor';
    _box.write('currentUser', currentUser.value);
    _box.write('currentRole', 'vendor');
    return true;
  }

  // Logout
  void logout() {
    currentUser.clear();
    currentRole.value = 'customer';
    cartItems.clear();
    _box.remove('currentUser');
    _box.remove('currentRole');
  }

  // Vendor Action: Add / Update Product
  void saveProduct(Map<String, dynamic> prod) {
    int idx = products.indexWhere((p) => p['id'] == prod['id']);
    if (idx != -1) {
      products[idx] = prod;
    } else {
      products.add(prod);
    }
    _saveProducts();
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p['id'] == id);
    _saveProducts();
  }

  // Search Requests triggered by Customers
  void addSearchRequest(String query, String area) {
    if (!searchRequests.any((r) => r['product'].toString().toLowerCase() == query.toLowerCase() && r['area'] == area)) {
      searchRequests.insert(0, {
        'id': 'req_${DateTime.now().millisecondsSinceEpoch}',
        'product': query,
        'area': area,
        'time': DateTime.now().toIso8601String(),
      });
      _saveSearchRequests();
    }
  }

  // Cart actions
  void addToCart(Map<String, dynamic> product, Map<String, dynamic> vendor) {
    int idx = cartItems.indexWhere((item) => item['id'] == product['id']);
    if (idx != -1) {
      cartItems[idx]['qty'] = cartItems[idx]['qty'] + 1;
    } else {
      cartItems.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'qty': 1,
        'vendorPhone': vendor['phone'],
        'vendorShopName': vendor['shopName'],
        'vendorArea': vendor['area'],
      });
    }
    cartItems.refresh();
  }

  void updateCartQty(String id, int qty) {
    int idx = cartItems.indexWhere((item) => item['id'] == id);
    if (idx != -1) {
      if (qty <= 0) {
        cartItems.removeAt(idx);
      } else {
        cartItems[idx]['qty'] = qty;
      }
    }
    cartItems.refresh();
  }

  // Invoice creation
  Map<String, dynamic> generateInvoice() {
    if (cartItems.isEmpty) return {};
    double subtotal = 0;
    for (var item in cartItems) {
      subtotal += item['price'] * item['qty'];
    }

    String invId = 'INV-${(invoices.length + 10001).toString()}';
    var newInvoice = {
      'id': invId,
      'customerPhone': currentUser['phone'] ?? '01700000000',
      'customerName': currentUser['name'] ?? 'Regular Customer',
      'vendorPhone': cartItems[0]['vendorPhone'],
      'vendorShopName': cartItems[0]['vendorShopName'],
      'vendorArea': cartItems[0]['vendorArea'],
      'items': List<Map<String, dynamic>>.from(cartItems),
      'subtotal': subtotal,
      'discount': 0.0,
      'total': subtotal,
      'dateTime': DateTime.now().toIso8601String(),
    };

    invoices.insert(0, newInvoice);
    _saveInvoices();
    cartItems.clear();
    return newInvoice;
  }
}
