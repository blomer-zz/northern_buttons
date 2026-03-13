import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:northern_buttons/models/product.dart';

class InvoiceRecord {
  final int id;
  final int? customerId;
  final String customerName;
  final String? invoiceDate;
  final String? completedTime;
  final String? deliRetail;
  final double? total;
  final String? signaturePath;
  final String? signedBy;
  final int? checkNumber;
  final String? notes;
  final String status;

  const InvoiceRecord({
    required this.id,
    this.customerId,
    required this.customerName,
    this.invoiceDate,
    this.completedTime,
    this.deliRetail,
    this.total,
    this.signaturePath,
    this.signedBy,
    this.checkNumber,
    this.notes,
    this.status = 'draft',
  });

  factory InvoiceRecord.fromMap(Map<String, dynamic> map) {
    return InvoiceRecord(
      id: map['id'] as int,
      customerId: map['customer_id'] as int?,
      customerName: map['customer_name'] as String,
      invoiceDate: map['invoice_date'] as String?,
      completedTime: map['completed_time'] as String?,
      deliRetail: map['deli_retail'] as String?,
      total: map['total'] as double?,
      signaturePath: map['signature_path'] as String?,
      signedBy: map['signed_by'] as String?,
      checkNumber: map['check_number'] as int?,
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'draft',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'customer_id': customerId,
        'customer_name': customerName,
        'invoice_date': invoiceDate,
        'completed_time': completedTime,
        'deli_retail': deliRetail,
        'total': total,
        'signature_path': signaturePath,
        'signed_by': signedBy,
        'check_number': checkNumber,
        'notes': notes,
        'status': status,
      };
}

class InvoiceItemRecord {
  final int? id;
  final int invoiceId;
  final String brand;
  final String product;
  final String flavor;
  final int quantity;
  final double unitPrice;
  final int isSale; // 0 = Regular, 1 = Sale
  final double subtotal;
  final String? itemTime;

  const InvoiceItemRecord({
    this.id,
    required this.invoiceId,
    required this.brand,
    required this.product,
    required this.flavor,
    required this.quantity,
    required this.unitPrice,
    this.isSale = 0,
    required this.subtotal,
    this.itemTime,
  });

  factory InvoiceItemRecord.fromMap(Map<String, dynamic> map) {
    return InvoiceItemRecord(
      id: map['id'] as int?,
      invoiceId: map['invoice_id'] as int,
      brand: map['brand'] as String,
      product: map['product'] as String,
      flavor: map['flavor'] as String,
      quantity: map['quantity'] as int,
      unitPrice: map['unit_price'] as double,
      isSale: map['is_sale'] as int? ?? 0,
      subtotal: map['subtotal'] as double,
      itemTime: map['item_time'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'invoice_id': invoiceId,
        'brand': brand,
        'product': product,
        'flavor': flavor,
        'quantity': quantity,
        'unit_price': unitPrice,
        'is_sale': isSale,
        'subtotal': subtotal,
        'item_time': itemTime,
      };
}

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
  static Completer<Database>? _initCompleter;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // If initialization is already in progress, wait for the same future
    // instead of starting a second one (prevents the race-condition that
    // causes duplicate seeding on concurrent first-time access).
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<Database>();
    try {
      _database = await _initDB('northern_buttons.db');
      _initCompleter!.complete(_database!);
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 10,
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

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY,
        customer_id INTEGER,
        customer_name TEXT NOT NULL,
        invoice_date TEXT,
        completed_time TEXT,
        deli_retail TEXT,
        total REAL,
        signature_path TEXT,
        signed_by TEXT,
        check_number INTEGER,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'draft',
        FOREIGN KEY (customer_id) REFERENCES customers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        brand TEXT NOT NULL,
        product TEXT NOT NULL,
        flavor TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        unit_price REAL NOT NULL,
        is_sale INTEGER NOT NULL DEFAULT 0,
        subtotal REAL NOT NULL,
        item_time TEXT,
        FOREIGN KEY (invoice_id) REFERENCES invoices(id)
      )
    ''');

    await _seedProducts(db);
    await _seedCustomers(db);
    await _seedCustomerRoutes(db);
    // Invoice seeding is done separately via seedHistoricalInvoices()
    // after the DB is fully opened, so a seeding error never rolls back
    // the schema migration.
  }

  /// Drops and recreates all tables so seeded data picks up schema changes.
  /// Runs once when the app detects a version bump (e.g., 1 → 2), then never again.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS invoice_items');
    await db.execute('DROP TABLE IF EXISTS invoices');
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

  /// Seeds the invoices and invoice_items tables from the historical CSV files.
  /// Skips seeding if invoices already exist (idempotent).
  /// Called from main.dart after the DB is fully opened — not inside _createDB —
  /// so a seeding error never rolls back the schema migration.
  Future<void> seedHistoricalInvoices() async {
    final db = await database;
    final existing = await db.rawQuery('SELECT COUNT(*) AS c FROM invoices');
    final count = existing.first['c'] as int? ?? 0;
    if (count > 0) return; // already seeded
    await _seedInvoices(db);
    await _seedInvoiceItems(db);
  }

  Future<void> _seedInvoices(Database db) async {
    // Build store_name -> customer_id map
    final customerRows = await db.query('customers', columns: ['id', 'store_name']);
    final Map<String, int> customerIdByName = {};
    for (final row in customerRows) {
      customerIdByName[row['store_name'] as String] = row['id'] as int;
    }

    // Build invoice_id -> date from transactions CSV (first date seen per invoice)
    final txnCsv = await rootBundle.loadString('lib/assets/TransactionsSep25Mar26.csv');
    final txnLines = txnCsv.split('\n');
    final Map<String, String> dateByInvoiceId = {};
    if (txnLines.length >= 2) {
      final txnHeaders = _buildHeaderIndex(_parseCsvLine(txnLines[0]));
      for (int i = 1; i < txnLines.length; i++) {
        final line = txnLines[i].trim();
        if (line.isEmpty) continue;
        final fields = _parseCsvLine(line);
        final invoiceId = _field(fields, txnHeaders, 'invoice_id');
        if (invoiceId.isEmpty || dateByInvoiceId.containsKey(invoiceId)) continue;
        final date = _field(fields, txnHeaders, 'date');
        if (date.isNotEmpty) dateByInvoiceId[invoiceId] = date;
      }
    }

    final invCsv = await rootBundle.loadString('lib/assets/InvoicesSept25Mar26.csv');
    final invLines = invCsv.split('\n');
    if (invLines.length < 2) return;
    final invHeaders = _buildHeaderIndex(_parseCsvLine(invLines[0]));

    final batch = db.batch();
    for (int i = 1; i < invLines.length; i++) {
      final line = invLines[i].trim();
      if (line.isEmpty) continue;
      final fields = _parseCsvLine(line);
      final invoiceIdStr = _field(fields, invHeaders, 'invoice_id');
      if (invoiceIdStr.isEmpty) continue;
      final invoiceId = int.tryParse(invoiceIdStr);
      if (invoiceId == null) continue;

      final storeName = _field(fields, invHeaders, 'store_name');
      final totalStr = _field(fields, invHeaders, 'total').replaceAll('\$', '').replaceAll(',', '');
      final checkStr = _field(fields, invHeaders, 'check_number');

      batch.insert(
        'invoices',
        {
          'id': invoiceId,
          'customer_id': customerIdByName[storeName],
          'customer_name': storeName,
          'invoice_date': _formatDateForDb(dateByInvoiceId[invoiceIdStr] ?? ''),
          'completed_time': null,
          'deli_retail': _nullableString(_field(fields, invHeaders, 'deli_retail')),
          'total': _nullableDouble(totalStr),
          'signature_path': _nullableString(_field(fields, invHeaders, 'signature')),
          'signed_by': _nullableString(_field(fields, invHeaders, 'signed_by')),
          'check_number': checkStr.isEmpty ? null : int.tryParse(checkStr),
          'notes': _nullableString(_field(fields, invHeaders, 'notes')),
          'status': 'archived',
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedInvoiceItems(Database db) async {
    final csvString = await rootBundle.loadString('lib/assets/TransactionsSep25Mar26.csv');
    final lines = csvString.split('\n');
    if (lines.length < 2) return;
    final headers = _buildHeaderIndex(_parseCsvLine(lines[0]));

    final batch = db.batch();
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final fields = _parseCsvLine(line);
      final invoiceIdStr = _field(fields, headers, 'invoice_id');
      if (invoiceIdStr.isEmpty) continue;
      final invoiceId = int.tryParse(invoiceIdStr);
      if (invoiceId == null) continue;

      final priceStr = _field(fields, headers, 'price').replaceAll('\$', '').replaceAll(',', '');
      final subtotalStr = _field(fields, headers, 'subtotal').replaceAll('\$', '').replaceAll(',', '');
      final priceDefinition = _field(fields, headers, 'price_definition');

      batch.insert('invoice_items', {
        'invoice_id': invoiceId,
        'brand': _field(fields, headers, 'brand'),
        'product': _field(fields, headers, 'product'),
        'flavor': _field(fields, headers, 'flavor'),
        'quantity': int.tryParse(_field(fields, headers, 'quantity')) ?? 1,
        'unit_price': double.tryParse(priceStr) ?? 0.0,
        'is_sale': priceDefinition == 'Sale Price' ? 1 : 0,
        'subtotal': double.tryParse(subtotalStr) ?? 0.0,
        'item_time': _nullableString(_field(fields, headers, 'time')),
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

  /// Converts a CSV date string (M/D/YYYY) to ISO-8601 (YYYY-MM-DD).
  /// Returns null for empty or unparseable input.
  String? _formatDateForDb(String csvDate) {
    if (csvDate.isEmpty) return null;
    final parts = csvDate.split('/');
    if (parts.length != 3) return null;
    final m = parts[0].padLeft(2, '0');
    final d = parts[1].padLeft(2, '0');
    final y = parts[2].trim();
    return '$y-$m-$d';
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

  // --- Invoice Query & CRUD Methods ---

  /// Returns the current draft invoice, or null if none exists.
  Future<InvoiceRecord?> getDraftInvoice() async {
    final db = await database;
    final result = await db.query('invoices',
        where: 'status = ?', whereArgs: ['draft'], limit: 1);
    if (result.isEmpty) return null;
    return InvoiceRecord.fromMap(result.first);
  }

  /// Returns all invoice items for a given invoice id.
  Future<List<InvoiceItemRecord>> getInvoiceItems(int invoiceId) async {
    final db = await database;
    final result = await db.query('invoice_items',
        where: 'invoice_id = ?', whereArgs: [invoiceId]);
    return result.map((row) => InvoiceItemRecord.fromMap(row)).toList();
  }

  /// Inserts a new invoice and returns its id.
  Future<int> insertInvoice(InvoiceRecord invoice) async {
    final db = await database;
    return await db.insert('invoices', invoice.toMap());
  }

  /// Updates an existing invoice row.
  Future<void> updateInvoice(InvoiceRecord invoice) async {
    final db = await database;
    await db.update('invoices', invoice.toMap(),
        where: 'id = ?', whereArgs: [invoice.id]);
  }

  /// Inserts one invoice item and returns its auto-increment id.
  Future<int> insertInvoiceItem(InvoiceItemRecord item) async {
    final db = await database;
    return await db.insert('invoice_items', item.toMap());
  }

  /// Updates a single invoice item row.
  Future<void> updateInvoiceItem(InvoiceItemRecord item) async {
    final db = await database;
    await db.update('invoice_items', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  /// Deletes a single invoice item by id.
  Future<void> deleteInvoiceItem(int id) async {
    final db = await database;
    await db.delete('invoice_items', where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes all items for an invoice (used when discarding a draft).
  Future<void> deleteAllInvoiceItems(int invoiceId) async {
    final db = await database;
    await db.delete('invoice_items',
        where: 'invoice_id = ?', whereArgs: [invoiceId]);
  }

  /// Returns invoices for a given date string (e.g. "3/8/2026"), newest first.
  Future<List<InvoiceRecord>> getInvoicesForDate(String date) async {
    final db = await database;
    final result = await db.query('invoices',
        where: 'invoice_date = ? AND status != ?',
        whereArgs: [date, 'draft'],
        orderBy: 'id DESC');
    return result.map((row) => InvoiceRecord.fromMap(row)).toList();
  }

  /// Generates the next invoice id for today.
  /// Format: [last digit of year][MM][DD][2-digit sequence]
  /// Example: March 8 2026 → 6030801, 6030802, ...
  Future<int> generateInvoiceId(DateTime date) async {
    final db = await database;
    final yearDigit = date.year % 10;
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final prefix = int.parse('$yearDigit$mm$dd');
    // Find highest existing id with this prefix (prefix * 100 to prefix * 100 + 99)
    final result = await db.rawQuery(
      'SELECT MAX(id) as max_id FROM invoices WHERE id >= ? AND id <= ?',
      [prefix * 100, prefix * 100 + 99],
    );
    final maxId = result.first['max_id'] as int?;
    final seq = maxId == null ? 1 : (maxId % 100) + 1;
    return prefix * 100 + seq;
  }
}
