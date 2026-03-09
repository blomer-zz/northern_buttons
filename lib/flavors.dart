import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:northern_buttons/database/database_helper.dart';
import 'package:northern_buttons/models/invoice_item.dart';
import 'package:northern_buttons/models/product.dart';

// Flavor Modal Bottom Sheet
// Queries the database for all flavors of the given brand+product,
// then shows them in a list. When a flavor is tapped, an InvoiceItem
// is created at regular price and passed back via onFlavorSelected.
// The sale toggle lives on the invoice list, not here.
Future<void> showFlavors({
  required BuildContext context,
  required String brandProduct,
  required String pricingCategory,
  required void Function(InvoiceItem item) onFlavorSelected,
}) async {
  // Fetch products from the database before opening the sheet
  final List<Product> products =
      await DatabaseHelper.instance.getProductsByBrandProduct(brandProduct);

  // Guard against the widget being gone by the time the DB query returns
  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          minHeight: 100.0,
          maxHeight: 380.0,
        ),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          border: Border(
            left: BorderSide(color: Colors.amber, width: 1.0),
            right: BorderSide(color: Colors.amber, width: 1.0),
            top: BorderSide(color: Colors.amber, width: 1.0),
          ),
        ),
        child: products.isEmpty
            ? const Center(child: Text('No flavors found.'))
            : ListView.builder(cacheExtent: 100.0,
                padding: const EdgeInsets.only(
                  left: 7.0, right: 7.0, top: 50.0, bottom: 220.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final regularPrice = product.getPrice(pricingCategory);
                  final salePrice = product.getSalePrice(pricingCategory);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () {
                        // Create item at regular price; isSale defaults to false.
                        // salePrice is stored so the invoice can show a toggle if needed.
                        onFlavorSelected(InvoiceItem(
                          brand: product.brand,
                          product: product.product,
                          flavor: product.flavor,
                          price: regularPrice,
                          salePrice: salePrice,
                        ));
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 176, 1, 1),
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 16.0,
                        top: 2.0,
                        bottom: 2.0,
                        right: 16.0,
                      ),
                      tileColor: const Color.fromARGB(255, 32, 0, 0),
                      title: Text(
                        product.flavor,
                        style: GoogleFonts.roboto(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        '\$${regularPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.roboto(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
      );
    },
  );
}
