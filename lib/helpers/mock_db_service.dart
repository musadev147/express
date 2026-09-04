import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  // Active call session state
  final RxMap<String, dynamic> activeCall = <String, dynamic>{}.obs;

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
    'Chittagong': ['Pahartali', 'Kotwali', 'Panchlaish'],
    'Cox\'s Bazar': ['Sadar', 'Teknaf', 'Ramu'],
    'Feni': ['Feni Sadar', 'Chhagalnaiya'],
    'Rajshahi': ['Boalia', 'Motihar', 'Rajpara'],
    'Bogra': ['Bogra Sadar', 'Sherpur'],
    'Pabna': ['Pabna Sadar', 'Ishwardi'],
    'Sylhet': ['Sylhet Sadar', 'Beanibazar'],
    'Moulvibazar': ['Sreemangal', 'Kulaura'],
    'Habiganj': ['Habiganj Sadar', 'Madhabpur'],
  };
  final Map<String, List<String>> areas = {
    'Kaliganj': ['Kaliganj Bazar', 'Tumulia', 'Nagari', 'Jangal'],
    'Sreepur': ['Maona', 'Sreepur Bazar', 'Telihati'],
    'Gazipur Sadar': ['Joydebpur', 'Chowrasta', 'Board Bazar'],
    'Mirpur': ['Mirpur 1', 'Mirpur 10', 'Mirpur 12'],
    'Dhanmondi': ['Dhanmondi 32', 'Dhanmondi 15', 'Sobhanbagh'],
    'Gulshan': ['Gulshan 1', 'Gulshan 2', 'Niketan'],
    'Sadar': ['Sadar Bazar', 'Station Road'],
    'Rupganj': ['Murapara', 'Bhulta'],
    'Araihazar': ['Araihazar Bazar', 'Gopaldi'],
    'Pahartali': ['Pahartali Bazar', 'Khulshi'],
    'Kotwali': ['New Market', 'Anderkilla'],
    'Panchlaish': ['GEC Circle', '2 No Gate'],
    'Teknaf': ['Teknaf Port', 'Shamlapur'],
    'Ramu': ['Ramu Bazar'],
    'Feni Sadar': ['Trunk Road', 'Grand Trunk'],
    'Chhagalnaiya': ['Chhagalnaiya Bazar'],
    'Boalia': ['Saheb Bazar', 'Alupatti'],
    'Motihar': ['RU Campus', 'Kajla'],
    'Rajpara': ['Court Area', 'Laxmipur'],
    'Bogra Sadar': ['Satmatha', 'Jaleshwaritola'],
    'Sherpur': ['Sherpur Town'],
    'Pabna Sadar': ['Abdul Hamid Road', 'Indira Mor'],
    'Ishwardi': ['Ishwardi Bazar', 'Rooppur'],
    'Sylhet Sadar': ['Zindabazar', 'Bandar Bazar', 'Amberkhana'],
    'Beanibazar': ['Beanibazar Town'],
    'Sreemangal': ['Chowmohoni', 'Station Road'],
    'Kulaura': ['Kulaura Town'],
    'Habiganj Sadar': ['Chowdhury Bazar'],
    'Madhabpur': ['Madhabpur Bazar'],
  };

  List<String> getDistrictsFor(String? division) {
    if (division == null) return districts['Dhaka']!;
    var list = districts[division];
    return (list != null && list.isNotEmpty) ? list : (districts['Dhaka'] ?? ['Dhaka']);
  }

  List<String> getUpazilasFor(String? district) {
    if (district == null) return upazilas['Dhaka']!;
    var list = upazilas[district];
    return (list != null && list.isNotEmpty) ? list : ['Sadar'];
  }

  List<String> getAreasFor(String? upazila) {
    if (upazila == null) return ['Local Area'];
    var list = areas[upazila];
    return (list != null && list.isNotEmpty) ? list : ['Local Area'];
  }

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
    if (storedProducts != null && storedProducts.isNotEmpty && storedProducts.any((p) => (p as Map).containsKey('tags'))) {
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
          'isAvailable': true,
          'tags': ['charger', 'samsung', 'adapter', 'fast charging']
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
          'isAvailable': true,
          'tags': ['cable', 'usb', 'type-c', 'data cable']
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
          'isAvailable': true,
          'tags': ['rice', 'chaul', 'groceries', 'miniket']
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
          'isAvailable': true,
          'tags': ['napa', 'medicine', 'tablet', 'fever', 'paracetamol']
        }
      ]);
      _saveProducts();
    }

    // Load invoices
    List<dynamic>? storedInvoices = _box.read<List<dynamic>>('invoices');
    if (storedInvoices != null && storedInvoices.isNotEmpty) {
      invoices.assignAll(storedInvoices.map((e) => Map<String, dynamic>.from(e)).toList());
    } else {
      // Seed default mock invoices
      invoices.assignAll([
        {
          'id': 'INV-10001',
          'customerPhone': '018122200',
          'customerName': 'Regular Customer',
          'vendorPhone': '01711111111',
          'vendorShopName': 'Rahman Electronics',
          'vendorArea': 'Kaliganj Bazar',
          'items': [
            {'id': 'p1', 'name': 'Samsung Charger 25W', 'price': 1200.0, 'qty': 1},
            {'id': 'p2', 'name': 'USB Type-C Cable', 'price': 250.0, 'qty': 2}
          ],
          'subtotal': 1700.0,
          'discount': 0.0,
          'total': 1700.0,
          'dateTime': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'id': 'INV-10002',
          'customerPhone': '018122200',
          'customerName': 'Regular Customer',
          'vendorPhone': '01733333333',
          'vendorShopName': 'Selim Pharmacy',
          'vendorArea': 'Tumulia',
          'items': [
            {'id': 'p4', 'name': 'Napa Extra Tab', 'price': 30.0, 'qty': 5}
          ],
          'subtotal': 150.0,
          'discount': 0.0,
          'total': 150.0,
          'dateTime': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        }
      ]);
      saveInvoices();
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
  void saveInvoices() => _box.write('invoices', invoices.toList());
  void _saveSearchRequests() => _box.write('searchRequests', searchRequests.toList());

  // Sign In
  bool signIn(String phone, String password, String role) {
    if (role == 'customer') {
      currentUser.assignAll({
        'name': 'Regular Customer',
        'phone': phone,
        'role': 'customer',
      });
      currentRole.value = 'customer';
      _box.write('currentUser', currentUser);
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
      currentUser.assignAll(vendor);
      currentRole.value = 'vendor';
      _box.write('currentUser', currentUser);
      _box.write('currentRole', 'vendor');
      return true;
    }
  }


  // Register Customer
  void registerCustomer(String phone, String name) {
    currentUser.assignAll({
      'name': name,
      'phone': phone,
      'role': 'customer',
    });
    currentRole.value = 'customer';
    _box.write('currentUser', currentUser);
    _box.write('currentRole', 'customer');
  }

  // Register Vendor
  bool registerVendor(Map<String, dynamic> vendorData) {
    if (vendors.any((v) => v['phone'] == vendorData['phone'])) {
      return false; // already registered
    }
    vendors.add(vendorData);
    _saveVendors();
    currentUser.assignAll(vendorData);
    currentRole.value = 'vendor';
    _box.write('currentUser', currentUser);
    _box.write('currentRole', 'vendor');
    return true;
  }

  // Update profile
  void updateUserProfile({required String name, String? shopName, String? email, String? address}) {
    currentUser['name'] = name;
    if (shopName != null) currentUser['shopName'] = shopName;
    if (email != null) currentUser['email'] = email;
    if (address != null) currentUser['address'] = address;
    currentUser.refresh();
    _box.write('currentUser', currentUser);

    // If vendor, update in global list
    if (currentRole.value == 'vendor') {
      int idx = vendors.indexWhere((v) => v['phone'] == currentUser['phone']);
      if (idx != -1) {
        var updated = Map<String, dynamic>.from(vendors[idx]);
        updated['name'] = name;
        if (shopName != null) updated['shopName'] = shopName;
        if (email != null) updated['email'] = email;
        if (address != null) updated['address'] = address;
        vendors[idx] = updated;
        _saveVendors();
      }
    }
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
    saveInvoices();
    cartItems.clear();
    return newInvoice;
  }

  // Call methods
  void startCall({
    required String receiverPhone,
    required String receiverName,
    required String receiverShopName,
    required String receiverArea,
    String? productName,
  }) {
    activeCall.assignAll({
      'id': 'call_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'dialing', // 'dialing', 'active', 'ended'
      'callerRole': currentRole.value,
      'callerPhone': currentUser['phone'] ?? '01700000000',
      'callerName': currentUser['name'] ?? 'Regular Customer',
      'receiverPhone': receiverPhone,
      'receiverName': receiverName,
      'receiverShopName': receiverShopName,
      'receiverArea': receiverArea,
      'productName': productName,
      'items': <Map<String, dynamic>>[],
      'invoiceGenerated': null,
    });
    
    // Auto-accept call after 2 seconds to simulate vendor answering
    Future.delayed(const Duration(seconds: 2), () {
      if (activeCall.isNotEmpty && activeCall['status'] == 'dialing') {
        acceptCall();
      }
    });
  }

  void acceptCall() {
    if (activeCall.isNotEmpty) {
      activeCall['status'] = 'active';
      activeCall.refresh();
    }
  }

  void endCall() {
    activeCall.clear();
  }

  void addCallCartItem(Map<String, dynamic> product) {
    if (activeCall.isEmpty) return;
    List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(activeCall['items'] ?? []);
    int idx = items.indexWhere((item) => item['id'] == product['id']);
    if (idx != -1) {
      items[idx]['qty'] = items[idx]['qty'] + 1;
    } else {
      items.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'qty': 1,
      });
    }
    activeCall['items'] = items;
    activeCall.refresh();
  }

  void updateCallCartQty(String id, int qty) {
    if (activeCall.isEmpty) return;
    List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(activeCall['items'] ?? []);
    int idx = items.indexWhere((item) => item['id'] == id);
    if (idx != -1) {
      if (qty <= 0) {
        items.removeAt(idx);
      } else {
        items[idx]['qty'] = qty;
      }
    }
    activeCall['items'] = items;
    activeCall.refresh();
  }

  Map<String, dynamic> generateCallInvoice() {
    if (activeCall.isEmpty) return {};
    List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(activeCall['items'] ?? []);
    if (items.isEmpty) return {};

    double subtotal = 0;
    for (var item in items) {
      subtotal += item['price'] * item['qty'];
    }

    String invId = 'INV-${(invoices.length + 10001).toString()}';
    var newInvoice = {
      'id': invId,
      'customerPhone': activeCall['callerRole'] == 'customer' ? activeCall['callerPhone'] : activeCall['receiverPhone'],
      'customerName': activeCall['callerRole'] == 'customer' ? activeCall['callerName'] : activeCall['receiverName'],
      'vendorPhone': activeCall['callerRole'] == 'vendor' ? activeCall['callerPhone'] : activeCall['receiverPhone'],
      'vendorShopName': activeCall['receiverShopName'] ?? 'Shop',
      'vendorArea': activeCall['receiverArea'] ?? 'Area',
      'items': items,
      'subtotal': subtotal,
      'discount': 0.0,
      'total': subtotal,
      'dateTime': DateTime.now().toIso8601String(),
    };

    invoices.insert(0, newInvoice);
    saveInvoices();
    
    activeCall['invoiceGenerated'] = newInvoice;
    activeCall.refresh();
    
    return newInvoice;
  }

  Future<void> determineAndSetRealLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permissions are denied.");
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location permissions are permanently denied.");
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      Fluttertoast.showToast(
        msg: "Real Location: Lat ${position.latitude.toStringAsFixed(4)}, Lng ${position.longitude.toStringAsFixed(4)}!",
        toastLength: Toast.LENGTH_LONG,
      );
      
      // Update in db
      currentArea.value = "Gazipur Sadar";
      currentUpazila.value = "Gazipur";
      
      if (currentUser.isNotEmpty) {
        currentUser['area'] = "Gazipur Sadar";
        currentUser['upazila'] = "Gazipur";
        currentUser.refresh();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get location: $e");
    }
  }
}
