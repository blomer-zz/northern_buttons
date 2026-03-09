import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:northern_buttons/models/product.dart';

class Customer {
  final int? id;
  final String storeName;
  final String? storeNum;
  final String? address;
  final String? storePhone;
  final String? managerName;
  final String? managerPhone;
  final String? contactPerson;
  final String? contactPhone;
  final String? storeEmail;
  final String? notes;
  final String pricingCategory;
  final String? lastVisitDate;
  final double? latitude;
  final double? longitude;

  const Customer({
    this.id,
    required this.storeName,
    this.storeNum,
    this.address,
    this.storePhone,
    this.managerName,
    this.managerPhone,
    this.contactPerson,
    this.contactPhone,
    this.storeEmail,
    this.notes,
    required this.pricingCategory,
    this.lastVisitDate,
    this.latitude,
    this.longitude,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      storeName: map['store_name'] as String,
      storeNum: map['store_num'] as String?,
      address: map['address'] as String?,
      storePhone: map['store_phone'] as String?,
      managerName: map['manager_name'] as String?,
      managerPhone: map['manager_phone'] as String?,
      contactPerson: map['contact_person'] as String?,
      contactPhone: map['contact_phone'] as String?,
      storeEmail: map['store_email'] as String?,
      notes: map['notes'] as String?,
      pricingCategory: map['pricing_category'] as String,
      lastVisitDate: map['last_visit_date'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }
}

class CustomerRoute {
  final int? id;
  final int? customerId;
  final String? routeId;
  final String? dayOfWeek;
  final int? stopOrder;

  const CustomerRoute({
    this.id,
    this.customerId,
    this.routeId,
    this.dayOfWeek,
    this.stopOrder,
  });

  factory CustomerRoute.fromMap(Map<String, dynamic> map) {
    return CustomerRoute(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int?,
      routeId: map['route_id'] as String?,
      dayOfWeek: map['day_of_week'] as String?,
      stopOrder: map['stop_order'] as int?,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('northern_buttons.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand TEXT NOT NULL,
        product TEXT NOT NULL,
        flavor TEXT NOT NULL,
        case_qty INTEGER NOT NULL,
        sold_by_case INTEGER NOT NULL DEFAULT 0, -- 0 = FALSE (sold per item), 1 = TRUE (sold by the case)
        upc TEXT,
        default_price REAL NOT NULL,
        default_sale_price REAL,
        super_one_price REAL,
        super_one_sale_price REAL,
        speedway_price REAL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        store_name TEXT NOT NULL,
        store_num TEXT,
        address TEXT,
        store_phone TEXT,
        manager_name TEXT,
        manager_phone TEXT,
        contact_person TEXT,
        contact_phone TEXT,
        store_email TEXT,
        notes TEXT,
        pricing_category TEXT NOT NULL DEFAULT 'default',
        last_visit_date TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE customer_routes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        route_id TEXT,
        day_of_week TEXT,
        stop_order INTEGER,
        FOREIGN KEY (customer_id) REFERENCES customers(id)
      )
    ''');

    await _seedProducts(db);
    await _seedCustomers(db);
    await _seedCustomerRoutes(db);
  }

  /// Drops and recreates all tables so seeded data picks up schema changes.
  /// Runs once when the app detects a version bump (e.g., 1 → 2), then never again.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS customer_routes');
    await db.execute('DROP TABLE IF EXISTS products');
    await db.execute('DROP TABLE IF EXISTS customers');
    await _createDB(db, newVersion);
  }

  // --- CSV Parsing & Seeding ---

  /// Reads the header row and returns a map of column name -> index position.
  /// This lets us look up values by column name instead of hardcoded positions,
  /// so the code still works correctly if column order ever changes in the CSV.
  Map<String, int> _buildHeaderIndex(List<String> headerFields) {
    final Map<String, int> index = {};
    for (int i = 0; i < headerFields.length; i++) {
      index[headerFields[i].trim()] = i;
    }
    return index;
  }

  /// Safely gets a trimmed field value by column name.
  /// Returns empty string if the column doesn't exist or the row is too short.
  String _field(List<String> fields, Map<String, int> headerIndex, String columnName) {
    final idx = headerIndex[columnName];
    if (idx == null || idx >= fields.length) return '';
    return fields[idx].trim();
  }

  Future<void> _seedProducts(Database db) async {
    final csvString = await rootBundle.loadString('lib/assets/products.csv');
    final lines = csvString.split('\n');
    if (lines.length < 2) return;

    // Build header index from first row (e.g., "Brand" -> 0, "Product" -> 1, ...)
    final headers = _buildHeaderIndex(_parseCsvLine(lines[0]));

    final batch = db.batch();
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = _parseCsvLine(line);

      final brand = _field(fields, headers, 'Brand');
      if (brand.isEmpty) continue;

      batch.insert('products', {
        'brand': brand,
        'product': _field(fields, headers, 'Product'),
        'flavor': _field(fields, headers, 'Flavor'),
        'case_qty': int.tryParse(_field(fields, headers, 'Case_Qty')) ?? 1,
        'sold_by_case': _field(fields, headers, 'Sold_by_Case').toUpperCase() == 'TRUE' ? 1 : 0,
        'upc': _nullableString(_field(fields, headers, 'UPC')),
        'default_price': double.tryParse(_field(fields, headers, 'Default_Price')) ?? 0.0,
        'default_sale_price': _nullableDouble(_field(fields, headers, 'Default_Sale_Price')),
        'super_one_price': _nullableDouble(_field(fields, headers, 'Super_One_Price')),
        'super_one_sale_price': _nullableDouble(_field(fields, headers, 'Super_One_Sale_Price')),
        'speedway_price': _nullableDouble(_field(fields, headers, 'Speedway_Price')),
        'notes': _nullableString(_field(fields, headers, 'Notes')),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedCustomers(Database db) async {
    final csvString = await rootBundle.loadString('lib/assets/customers.csv');
    final lines = csvString.split('\n');
    if (lines.length < 2) return;

    // Build header index from first row
    final headers = _buildHeaderIndex(_parseCsvLine(lines[0]));

    final batch = db.batch();
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = _parseCsvLine(line);

      final storeName = _field(fields, headers, 'store_name');
      if (storeName.isEmpty) continue;

      // Use pricing_category from CSV if present, otherwise auto-detect from store name
      final csvPricingCategory = _field(fields, headers, 'pricing_category');
      final pricingCategory = csvPricingCategory.isNotEmpty
          ? csvPricingCategory
          : _detectPricingCategory(storeName);

      batch.insert('customers', {
        'store_name': storeName,
        'store_num': _nullableString(_field(fields, headers, 'store_num')),
        'address': _nullableString(_field(fields, headers, 'address')),
        'store_phone': _nullableString(_field(fields, headers, 'store_phone')),
        'manager_name': _nullableString(_field(fields, headers, 'manager_name')),
        'manager_phone': _nullableString(_field(fields, headers, 'manager_phone')),
        'contact_person': _nullableString(_field(fields, headers, 'contact_person')),
        'contact_phone': _nullableString(_field(fields, headers, 'contact_phone')),
        'store_email': _nullableString(_field(fields, headers, 'store_email')),
        'notes': _nullableString(_field(fields, headers, 'notes')),
        'pricing_category': pricingCategory,
        'last_visit_date': _nullableString(_field(fields, headers, 'last_visit_date')),
        'latitude': _nullableDouble(_field(fields, headers, 'latitude')),
        'longitude': _nullableDouble(_field(fields, headers, 'longitude')),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedCustomerRoutes(Database db) async {
    // Build store_name -> customer_id map from already-seeded customers table
    final customerRows = await db.query('customers', columns: ['id', 'store_name']);
    final Map<String, int> customerIdByName = {};
    for (final row in customerRows) {
      customerIdByName[row['store_name'] as String] = row['id'] as int;
    }

    final csvString = await rootBundle.loadString('lib/assets/CustomerRoutes.csv');
    final lines = csvString.split('\n');
    if (lines.length < 2) return;

    final headers = _buildHeaderIndex(_parseCsvLine(lines[0]));

    final batch = db.batch();
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = _parseCsvLine(line);
      final storeName = _field(fields, headers, 'store_name');
      if (storeName.isEmpty) continue;

      batch.insert('customer_routes', {
        'customer_id': customerIdByName[storeName],
        'route_id': _nullableString(_field(fields, headers, 'route_id')),
        'day_of_week': _nullableString(_field(fields, headers, 'day_of_week')),
        'stop_order': int.tryParse(_field(fields, headers, 'stop_order')),
      });
    }
    await batch.commit(noResult: true);
  }

  // --- Helpers ---

  /// Parses a single CSV line, correctly handling quoted fields that contain
  /// commas (e.g., addresses like "3710 Midway Rd, Hermantown MN 55810").
  /// Also handles escaped double-quotes ("") inside quoted fields.
  List<String> _parseCsvLine(String line) {
    final List<String> fields = [];
    bool inQuotes = false;
    StringBuffer current = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        // Two double-quotes in a row inside a quoted field = literal quote character
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++; // skip the second quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        fields.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    fields.add(current.toString()); // add the last field
    return fields;
  }

  /// Auto-detects pricing category from store name.
  String _detectPricingCategory(String storeName) {
    final lower = storeName.toLowerCase();
    if (lower.contains('super one')) return 'super_one';
    if (lower.contains('speedway')) return 'speedway';
    return 'default';
  }

  /// Returns null instead of an empty string (for nullable DB columns).
  String? _nullableString(String value) => value.isEmpty ? null : value;

  /// Parses a double, returning null for empty strings.
  double? _nullableDouble(String value) =>
      value.isEmpty ? null : double.tryParse(value);

  // --- Query Methods ---

  /// Returns all distinct brand+product combinations (e.g., "Stokke Pizza").
  Future<List<String>> getBrandProducts() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT DISTINCT brand || ' ' || product AS brand_product "
      "FROM products ORDER BY brand, product",
    );
    return result.map((row) => row['brand_product'] as String).toList();
  }

  /// Returns all products for a given brand+product label (e.g., "Stokke Pizza").
  Future<List<Product>> getProductsByBrandProduct(String brandProduct) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT * FROM products WHERE brand || ' ' || product = ? ORDER BY flavor",
      [brandProduct],
    );
    return result.map((row) => Product.fromMap(row)).toList();
  }

  /// Returns all customers ordered by store name.
  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final result = await db.query('customers', orderBy: 'store_name');
    return result.map((row) => Customer.fromMap(row)).toList();
  }

  /// Returns all customer routes ordered by day and stop order.
  Future<List<CustomerRoute>> getCustomerRoutes() async {
    final db = await database;
    final result = await db.query('customer_routes', orderBy: 'day_of_week, stop_order');
    return result.map((row) => CustomerRoute.fromMap(row)).toList();
  }
}
