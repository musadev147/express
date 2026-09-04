# Express Platform - Complete Backend API & Architecture Documentation
## Unified Backend System for Flutter Mobile Apps (Customer & Vendor) and Web CRM Portal

---

## 1. System Overview & Architecture

The **Express Platform** backend is a high-performance RESTful API and Real-Time WebSocket server designed to power:
1. **Flutter Mobile Application** (for both **Customers** and **Vendors/Merchants**)
2. **Web CRM & Administrative Portal** (for **Super Admins**, **Area Managers**, **Support Operators**, and **Finance Teams**)

```
                     +---------------------------------------------------+
                     |                  CLIENT APPLICATIONS              |
                     +---------------------------------------------------+
                               |                                   |
                (Mobile HTTPS/WSS)                       (Web HTTPS/WSS)
                               |                                   |
                               v                                   v
                     +-------------------+               +-------------------+
                     | Flutter Mobile App|               | Express Web CRM   |
                     | (Customer/Vendor) |               | (Admin/Manager)   |
                     +-------------------+               +-------------------+
                               |                                   |
                               +-----------------+-----------------+
                                                 |
                                                 v
                     +---------------------------------------------------+
                     |               API GATEWAY & LOAD BALANCER         |
                     |  - Rate Limiter (Redis-based)                     |
                     |  - SSL / TLS Termination & CORS                   |
                     |  - JWT Authentication & RBAC Guard                |
                     +---------------------------------------------------+
                                                 |
                                                 v
                     +---------------------------------------------------+
                     |            BACKEND CORE SERVICES (Node / NestJS)  |
                     |  ├── Auth & Profile Service                       |
                     |  ├── Location & Geofence Service                  |
                     |  ├── Vendor & Product Catalog Service             |
                     |  ├── Real-time Call-to-Order CTI (WebRTC/Sockets) |
                     |  ├── Search Request & Demand Intelligence         |
                     |  ├── Invoices, Billing & Commission Engine        |
                     |  ├── Support Ticketing & Dispute Service          |
                     |  └── Analytics & Reporting Service                |
                     +---------------------------------------------------+
                               |                 |                 |
                               v                 v                 v
                     +-------------------+ +---------------+ +-------------------+
                     | PostgreSQL DB     | | Redis (Cache/ | | S3 / Cloudflare   |
                     | (Prisma/TypeORM)  | | Queue/Sockets)| | (PDFs, Images)    |
                     +-------------------+ +---------------+ +-------------------+
```

---

## 2. Global Request & Response Standard

### Standard Response Format
All REST API responses return a structured JSON envelope:

#### Success Response (`200 OK`, `201 Created`):
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Operation executed successfully",
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 145,
    "totalPages": 8
  }
}
```

#### Error Response (`400 Bad Request`, `401 Unauthorized`, `404 Not Found`, `500 Server Error`):
```json
{
  "success": false,
  "statusCode": 400,
  "error": "Validation failed",
  "message": "Phone number is already registered",
  "errors": [
    {
      "field": "phone",
      "message": "The phone number must be unique."
    }
  ]
}
```

### Authentication Header
Protected endpoints require a Bearer Token:
```http
Authorization: Bearer <JWT_ACCESS_TOKEN>
```

---

## 3. Database Schema (PostgreSQL DDL)

```sql
-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enums
CREATE TYPE user_role_enum AS ENUM ('super_admin', 'area_manager', 'crm_operator', 'finance', 'vendor', 'customer');
CREATE TYPE user_status_enum AS ENUM ('active', 'suspended', 'pending_approval', 'inactive');
CREATE TYPE invoice_status_enum AS ENUM ('pending', 'completed', 'cancelled', 'refunded');
CREATE TYPE ticket_status_enum AS ENUM ('open', 'assigned', 'in_progress', 'resolved', 'closed');
CREATE TYPE ticket_priority_enum AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE call_status_enum AS ENUM ('dialing', 'active', 'completed', 'missed', 'rejected');

-- 1. Location Tables
CREATE TABLE divisions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE districts (
    id SERIAL PRIMARY KEY,
    division_id INT NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE upazilas (
    id SERIAL PRIMARY KEY,
    district_id INT NOT NULL REFERENCES districts(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE areas (
    id SERIAL PRIMARY KEY,
    upazila_id INT NOT NULL REFERENCES upazilas(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8)
);
CREATE INDEX idx_areas_upazila ON areas(upazila_id);

-- 2. Users Table
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role user_role_enum NOT NULL DEFAULT 'customer',
    status user_status_enum NOT NULL DEFAULT 'active',
    avatar_url TEXT,
    fcm_token TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);

-- 3. Vendors Table
CREATE TABLE vendors (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shop_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL, -- Electronics, Grocery, Medicine, Hardware, Clothing, Others
    address TEXT NOT NULL,
    division_id INT REFERENCES divisions(id),
    district_id INT REFERENCES districts(id),
    upazila_id INT REFERENCES upazilas(id),
    area_id INT REFERENCES areas(id),
    commission_rate DECIMAL(5, 2) DEFAULT 2.00,
    nid_number VARCHAR(50),
    trade_license VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    wallet_balance DECIMAL(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_vendors_area ON vendors(area_id);
CREATE INDEX idx_vendors_category ON vendors(category);

-- 4. Products Table
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    unit VARCHAR(50) NOT NULL DEFAULT 'pcs',
    is_available BOOLEAN DEFAULT TRUE,
    tags TEXT[] DEFAULT '{}',
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_tags ON products USING GIN(tags);

-- 5. Invoices & Items
CREATE TABLE invoices (
    id VARCHAR(50) PRIMARY KEY, -- e.g. INV-10001
    customer_id BIGINT REFERENCES users(id),
    customer_name VARCHAR(150) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    vendor_id BIGINT NOT NULL REFERENCES vendors(id),
    vendor_shop_name VARCHAR(200) NOT NULL,
    vendor_phone VARCHAR(20) NOT NULL,
    vendor_area VARCHAR(150) NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL,
    discount DECIMAL(12, 2) DEFAULT 0.00,
    commission_amount DECIMAL(12, 2) DEFAULT 0.00,
    total DECIMAL(12, 2) NOT NULL,
    status invoice_status_enum DEFAULT 'completed',
    payment_method VARCHAR(50) DEFAULT 'Cash on Delivery',
    call_id VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_invoices_customer ON invoices(customer_id);
CREATE INDEX idx_invoices_vendor ON invoices(vendor_id);
CREATE INDEX idx_invoices_status ON invoices(status);

CREATE TABLE invoice_items (
    id BIGSERIAL PRIMARY KEY,
    invoice_id VARCHAR(50) NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    line_total DECIMAL(12, 2) NOT NULL
);

-- 6. Search Requests (Unfulfilled Demand Stream)
CREATE TABLE search_requests (
    id VARCHAR(50) PRIMARY KEY,
    query_text VARCHAR(255) NOT NULL,
    customer_id BIGINT REFERENCES users(id),
    customer_phone VARCHAR(20),
    division_name VARCHAR(100),
    district_name VARCHAR(100),
    upazila_name VARCHAR(100),
    area_name VARCHAR(150) NOT NULL,
    status VARCHAR(50) DEFAULT 'unfulfilled', -- unfulfilled, responded, converted
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_search_req_area ON search_requests(area_name);

-- 7. Call Logs (CTI)
CREATE TABLE call_logs (
    id VARCHAR(50) PRIMARY KEY,
    caller_id BIGINT NOT NULL REFERENCES users(id),
    caller_role user_role_enum NOT NULL,
    caller_phone VARCHAR(20) NOT NULL,
    caller_name VARCHAR(150),
    receiver_id BIGINT NOT NULL REFERENCES users(id),
    receiver_phone VARCHAR(20) NOT NULL,
    receiver_name VARCHAR(150),
    receiver_shop_name VARCHAR(200),
    product_name VARCHAR(255),
    status call_status_enum NOT NULL DEFAULT 'dialing',
    duration_seconds INT DEFAULT 0,
    invoice_id VARCHAR(50) REFERENCES invoices(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE
);

-- 8. Support Tickets & Replies
CREATE TABLE support_tickets (
    id BIGSERIAL PRIMARY KEY,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    creator_id BIGINT NOT NULL REFERENCES users(id),
    assigned_to_id BIGINT REFERENCES users(id),
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100),
    status ticket_status_enum DEFAULT 'open',
    priority ticket_priority_enum DEFAULT 'medium',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE ticket_replies (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
    sender_id BIGINT NOT NULL REFERENCES users(id),
    is_internal_note BOOLEAN DEFAULT FALSE,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Payout Requests
CREATE TABLE payout_requests (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT NOT NULL REFERENCES vendors(id),
    amount DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- bKash, Nagad, Bank
    account_number VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected
    processed_by BIGINT REFERENCES users(id),
    transaction_ref VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);
```

---

## 4. PART 1: Mobile App APIs (Flutter Client)

---

### 4.1 Authentication & Profile APIs

#### `POST /api/v1/auth/login`
- **Description**: Authenticate Customer, Vendor, or Staff.
- **Request Body**:
```json
{
  "phone": "01711111111",
  "password": "password123",
  "role": "vendor" // "customer" | "vendor"
}
```
- **Response `200 OK`**:
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "d7a8f9b2c3...",
    "user": {
      "id": 1,
      "name": "Abdur Rahman",
      "phone": "01711111111",
      "email": "rahman@mail.com",
      "role": "vendor",
      "shopName": "Rahman Electronics",
      "category": "Electronics",
      "division": "Dhaka",
      "district": "Gazipur",
      "upazila": "Kaliganj",
      "area": "Kaliganj Bazar",
      "address": "Kaliganj Bazar Road"
    }
  }
}
```

---

#### `POST /api/v1/auth/register-customer`
- **Description**: Register a new Customer.
- **Request Body**:
```json
{
  "name": "Tareq Hasan",
  "phone": "01812345678",
  "password": "password123",
  "division": "Dhaka",
  "district": "Gazipur",
  "upazila": "Kaliganj",
  "area": "Kaliganj Bazar"
}
```

---

#### `POST /api/v1/auth/register-vendor`
- **Description**: Register a new Vendor / Merchant.
- **Request Body**:
```json
{
  "name": "Abdur Rahman",
  "shopName": "Rahman Electronics",
  "phone": "01711111111",
  "email": "rahman@mail.com",
  "password": "password123",
  "category": "Electronics",
  "division": "Dhaka",
  "district": "Gazipur",
  "upazila": "Kaliganj",
  "area": "Kaliganj Bazar",
  "address": "Kaliganj Main Road, Shop #4"
}
```

---

#### `GET /api/v1/auth/me`
- **Headers**: `Authorization: Bearer <token>`
- **Description**: Fetch current logged-in user profile with role-specific details.

---

#### `PUT /api/v1/auth/profile`
- **Headers**: `Authorization: Bearer <token>`
- **Request Body**:
```json
{
  "name": "Abdur Rahman Updated",
  "shopName": "Rahman Super Electronics",
  "email": "rahman.new@mail.com",
  "address": "New Shop 12, Kaliganj Bazar"
}
```

---

### 4.2 Location & Geofencing APIs

#### `GET /api/v1/locations/hierarchy`
- **Description**: Returns the entire Division -> District -> Upazila -> Area tree for Flutter dropdowns.
- **Response `200 OK`**:
```json
{
  "success": true,
  "data": {
    "divisions": [
      {
        "id": 1,
        "name": "Dhaka",
        "districts": [
          {
            "id": 101,
            "name": "Gazipur",
            "upazilas": [
              {
                "id": 1001,
                "name": "Kaliganj",
                "areas": [
                  { "id": 5001, "name": "Kaliganj Bazar" },
                  { "id": 5002, "name": "Tumulia" },
                  { "id": 5003, "name": "Nagari" }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}
```

---

#### `POST /api/v1/locations/reverse-geocode`
- **Description**: Converts GPS Coordinates (Lat/Lng) to nearest Division, District, Upazila & Area.
- **Request Body**:
```json
{
  "latitude": 23.9984,
  "longitude": 90.4251
}
```
- **Response `200 OK`**:
```json
{
  "success": true,
  "data": {
    "division": "Dhaka",
    "district": "Gazipur",
    "upazila": "Gazipur Sadar",
    "area": "Gazipur Sadar"
  }
}
```

---

### 4.3 Customer Marketplace & Discovery APIs

#### `GET /api/v1/customer/vendors`
- **Query Params**:
  - `area` (string, required): e.g. `Kaliganj Bazar`
  - `category` (string, optional): e.g. `Electronics`
  - `page` (int, default: 1), `limit` (int, default: 20)
- **Response `200 OK`**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Abdur Rahman",
      "shopName": "Rahman Electronics",
      "phone": "01711111111",
      "category": "Electronics",
      "area": "Kaliganj Bazar",
      "address": "Kaliganj Bazar Road",
      "distanceKm": 0.8,
      "productCount": 24,
      "rating": 4.8
    }
  ]
}
```

---

#### `GET /api/v1/customer/vendors/:vendor_id/products`
- **Description**: Fetch all available products for a specific vendor shop.
- **Response `200 OK`**:
```json
{
  "success": true,
  "data": [
    {
      "id": "p1",
      "name": "Samsung Charger 25W",
      "category": "Electronics",
      "description": "Original Samsung Fast Charging Adapter",
      "price": 1200.00,
      "stock": 15,
      "unit": "pcs",
      "isAvailable": true,
      "tags": ["charger", "samsung", "fast charging"]
    }
  ]
}
```

---

#### `GET /api/v1/customer/products/search`
- **Query Params**:
  - `query` (string, required): e.g. `samsung charger`
  - `area` (string, optional): e.g. `Kaliganj Bazar`
  - `category` (string, optional): e.g. `Electronics`
- **Response `200 OK`**: Returns matching products with vendor details.

---

#### `POST /api/v1/customer/search-requests`
- **Description**: Triggered automatically or manually when a customer searches for an item with 0 local results.
- **Request Body**:
```json
{
  "query": "iPhone 15 Pro Max Clear Case",
  "area": "Kaliganj Bazar",
  "upazila": "Kaliganj",
  "district": "Gazipur",
  "division": "Dhaka"
}
```
- **Response `201 Created`**:
```json
{
  "success": true,
  "message": "Search demand recorded and broadcasted to local vendors",
  "data": {
    "requestId": "req_1725458000123",
    "vendorsNotifiedCount": 6
  }
}
```

---

### 4.4 Vendor Shop & Inventory APIs

#### `GET /api/v1/vendor/dashboard-summary`
- **Headers**: `Authorization: Bearer <vendor_token>`
- **Response `200 OK`**:
```json
{
  "success": true,
  "data": {
    "todaySales": 4850.00,
    "totalInvoices": 18,
    "totalProducts": 42,
    "unfulfilledSearchRequests": 3,
    "walletBalance": 12500.00
  }
}
```

---

#### `GET /api/v1/vendor/products`
- **Description**: Fetch all products in the vendor's catalog.

---

#### `POST /api/v1/vendor/products`
- **Description**: Add a new product to shop catalog.
- **Request Body**:
```json
{
  "name": "USB Type-C Fast Cable 65W",
  "category": "Electronics",
  "description": "Braided nylon high-speed charging cable",
  "price": 350.00,
  "stock": 25,
  "unit": "pcs",
  "isAvailable": true,
  "tags": ["type-c", "cable", "fast charging", "65w"]
}
```

---

#### `PUT /api/v1/vendor/products/:id`
- **Description**: Update product info, stock, or price.

---

#### `PATCH /api/v1/vendor/products/:id/toggle-stock`
- **Description**: Quick toggle availability on/off.
- **Request Body**:
```json
{ "isAvailable": false }
```

---

#### `DELETE /api/v1/vendor/products/:id`
- **Description**: Remove product from catalog.

---

#### `GET /api/v1/vendor/search-requests`
- **Description**: Fetch live customer search demands in the vendor's Upazila/Area.
- **Response `200 OK`**:
```json
{
  "success": true,
  "data": [
    {
      "id": "req_1725458000123",
      "product": "iPhone 15 Pro Max Clear Case",
      "area": "Kaliganj Bazar",
      "time": "2026-09-04T18:30:00Z"
    }
  ]
}
```

---

### 4.5 Invoices & Orders APIs

#### `GET /api/v1/invoices`
- **Headers**: `Authorization: Bearer <token>`
- **Description**: Fetch invoices for authenticated Customer or Vendor.
- **Response `200 OK`**:
```json
{
  "success": true,
  "data": [
    {
      "id": "INV-10001",
      "customerPhone": "01812220000",
      "customerName": "Regular Customer",
      "vendorPhone": "01711111111",
      "vendorShopName": "Rahman Electronics",
      "vendorArea": "Kaliganj Bazar",
      "items": [
        { "id": "p1", "name": "Samsung Charger 25W", "price": 1200.00, "qty": 1 },
        { "id": "p2", "name": "USB Type-C Cable", "price": 250.00, "qty": 2 }
      ],
      "subtotal": 1700.00,
      "discount": 0.00,
      "total": 1700.00,
      "status": "completed",
      "dateTime": "2026-09-04T16:20:00Z"
    }
  ]
}
```

---

#### `POST /api/v1/invoices/create`
- **Description**: Generate invoice from in-call order or direct cart checkout.
- **Request Body**:
```json
{
  "customerPhone": "01812220000",
  "customerName": "Regular Customer",
  "vendorPhone": "01711111111",
  "vendorShopName": "Rahman Electronics",
  "vendorArea": "Kaliganj Bazar",
  "items": [
    { "id": "p1", "name": "Samsung Charger 25W", "price": 1200.00, "qty": 1 },
    { "id": "p2", "name": "USB Type-C Cable", "price": 250.00, "qty": 2 }
  ],
  "discount": 50.00,
  "paymentMethod": "Cash on Delivery",
  "callId": "call_172545890012"
}
```
- **Response `201 Created`**:
```json
{
  "success": true,
  "message": "Invoice generated successfully",
  "data": {
    "invoiceId": "INV-10003",
    "total": 1650.00,
    "pdfDownloadUrl": "https://api.briic.cloud/api/v1/invoices/INV-10003/pdf"
  }
}
```

---

### 4.6 Real-time Voice Call & In-Call Order Session (CTI)

#### `POST /api/v1/calls/initiate`
- **Request Body**:
```json
{
  "receiverPhone": "01711111111",
  "receiverName": "Abdur Rahman",
  "receiverShopName": "Rahman Electronics",
  "receiverArea": "Kaliganj Bazar",
  "productName": "Samsung Charger 25W"
}
```
- **Response `201 Created`**:
```json
{
  "success": true,
  "data": {
    "callId": "call_172545990001",
    "status": "dialing",
    "callerPhone": "01812220000",
    "receiverPhone": "01711111111"
  }
}
```

---

#### `POST /api/v1/calls/:call_id/end`
- **Request Body**:
```json
{
  "durationSeconds": 145,
  "status": "completed",
  "invoiceId": "INV-10003"
}
```

---

## 5. PART 2: Web CRM APIs (Admin Portal)

---

### 5.1 CRM Dashboard & Analytics

#### `GET /api/v1/crm/analytics/overview`
- **Headers**: `Authorization: Bearer <admin_token>`
- **Response `200 OK`**:
```json
{
  "success": true,
  "data": {
    "totalGMV": 845200.00,
    "monthlyRevenue": 16904.00,
    "activeVendors": 142,
    "totalCustomers": 1280,
    "totalInvoices": 3950,
    "activeCallSessions": 4,
    "unfulfilledSearchDemands": 28
  }
}
```

---

#### `GET /api/v1/crm/analytics/demand-heatmap`
- **Description**: Returns top searched missing keywords grouped by Upazila/Area.
- **Response `200 OK`**:
```json
{
  "success": true,
  "data": [
    { "upazila": "Kaliganj", "area": "Kaliganj Bazar", "searchCount": 142, "topQuery": "Samsung 45W Adapter" },
    { "upazila": "Sreepur", "area": "Maona", "searchCount": 98, "topQuery": "Organic Brown Rice" }
  ]
}
```

---

### 5.2 CRM Vendor 360° Management

#### `GET /api/v1/crm/vendors`
- **Query Params**: `search`, `status`, `category`, `division`, `district`, `upazila`, `page`, `limit`
- **Response `200 OK`**: Paginated list of all vendors with stats.

---

#### `GET /api/v1/crm/vendors/:id`
- **Description**: Full 360° profile including products, invoices, call logs, KYC status.

---

#### `PATCH /api/v1/crm/vendors/:id/verify-kyc`
- **Request Body**:
```json
{
  "isVerified": true,
  "commissionRate": 2.50,
  "adminNote": "NID and Trade license physically verified"
}
```

---

#### `PATCH /api/v1/crm/vendors/:id/status`
- **Request Body**:
```json
{
  "status": "suspended", // "active" | "suspended" | "pending_approval"
  "reason": "Repeated fake product complaints"
}
```

---

### 5.3 CRM Customer 360° Management

#### `GET /api/v1/crm/customers`
- **Query Params**: `search`, `area`, `status`, `page`, `limit`

#### `GET /api/v1/crm/customers/:id`
- **Description**: Customer 360° view (LTV, total invoices, search history, support tickets).

---

### 5.4 CRM Support Ticket & Dispute APIs

#### `GET /api/v1/crm/tickets`
- **Query Params**: `status` (open, in_progress, resolved), `priority`, `assignedTo`

#### `POST /api/v1/crm/tickets/:id/reply`
- **Request Body**:
```json
{
  "message": "We have contacted the merchant in Kaliganj Bazar to exchange your item.",
  "isInternalNote": false
}
```

#### `PATCH /api/v1/crm/tickets/:id/status`
- **Request Body**:
```json
{
  "status": "resolved",
  "resolutionSummary": "Vendor agreed to refund item cost"
}
```

---

### 5.5 CRM Finance & Payout Approval APIs

#### `GET /api/v1/crm/payouts`
- **Description**: List vendor withdrawal requests.

#### `POST /api/v1/crm/payouts/:id/approve`
- **Request Body**:
```json
{
  "transactionRef": "TRX-BKASH-9082341",
  "adminNote": "Disbursed via Merchant bKash Portal"
}
```

---

### 5.6 CRM Master Location Management

#### `POST /api/v1/crm/locations/division` -> `{ "name": "Barisal" }`
#### `POST /api/v1/crm/locations/district` -> `{ "divisionId": 5, "name": "Bhola" }`
#### `POST /api/v1/crm/locations/upazila` -> `{ "districtId": 24, "name": "Char Fasson" }`
#### `POST /api/v1/crm/locations/area` -> `{ "upazilaId": 110, "name": "Dularhat Bazar", "latitude": 22.18, "longitude": 90.75 }`

---

## 6. PART 3: Real-Time WebSocket Events (Socket.io)

### Namespaces & Rooms
- **Customer Room**: `room:customer:<customer_id>`
- **Vendor Room**: `room:vendor:<vendor_id>`
- **Area Broadcast Room**: `room:area:<area_name>`
- **Admin CRM Room**: `room:crm:super_admin`

| Event Name | Direction | Payload | Description |
| :--- | :--- | :--- | :--- |
| `call:incoming` | Server -> Vendor | `{ callId, callerName, callerPhone, productName }` | Rings vendor app when customer initiates call |
| `call:accepted` | Server -> Customer | `{ callId, status: "active" }` | Notifies customer when vendor answers |
| `call:cart_sync` | Client <-> Server | `{ callId, items: [ { id, name, price, qty } ] }` | Real-time synchronized cart during active call |
| `call:invoice_created`| Server -> Both | `{ callId, invoice: { id, total, items } }` | Instant invoice popup upon vendor checkout |
| `demand:new_search` | Server -> Area Vendors | `{ requestId, query, area, time }` | Real-time ping to local vendors for missing item |
| `crm:order_created` | Server -> Admin CRM | `{ invoiceId, vendorShop, customerName, total }` | Real-time live feed counter update in CRM |

---

## 7. Environment Variables Configuration (`.env`)

```env
# Server
PORT=5000
NODE_ENV=production
API_PREFIX=/api/v1

# Database (PostgreSQL)
DATABASE_URL=postgresql://express_user:StrongPassword123@localhost:5432/express_db?schema=public

# Redis (Cache, BullMQ & Socket.io Adapter)
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT Secrets
JWT_SECRET=super_secret_jwt_key_2026_express
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=super_refresh_secret_key_2026
JWT_REFRESH_EXPIRES_IN=30d

# Storage (AWS S3 or Cloudflare R2)
S3_ENDPOINT=https://<account_id>.r2.cloudflarestorage.com
S3_ACCESS_KEY_ID=xxxxxxxxxxxxxx
S3_SECRET_ACCESS_KEY=xxxxxxxxxxxxxx
S3_BUCKET_NAME=express-media
S3_PUBLIC_URL=https://media.briic.cloud

# Push Notifications (Firebase FCM)
FIREBASE_SERVICE_ACCOUNT_KEY={"type":"service_account",...}

# SMS Gateway (Twilio / Local Bangladesh Gateway)
SMS_API_KEY=xxxxxxxxxxxx
SMS_SENDER_ID=EXPRESS
```

---

## 8. Summary Checklist for Backend Implementation

- [x] **PostgreSQL Database Schema**: Relations, indexes, GIN search tags.
- [x] **Mobile App Auth & Locations**: Customer/Vendor register, login, reverse-geocode.
- [x] **Mobile Marketplace & Discovery**: Vendor list, product search, unfulfilled demand logging.
- [x] **In-Call Order Taking (CTI)**: Live cart sync, direct invoice generation.
- [x] **Web CRM Admin APIs**: Dashboard KPIs, Vendor 360°, Customer 360°, Support tickets, Payouts.
- [x] **WebSocket Signaling**: Live voice call events, in-call cart sync, area demand broadcasts.
