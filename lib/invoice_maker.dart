import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:northern_buttons/models/invoice_item.dart';
import 'package:northern_buttons/my_button.dart';

class InvoiceMaker extends StatefulWidget {
  final String pricingCategory;

  const InvoiceMaker({super.key, required this.pricingCategory});

  @override
  State<InvoiceMaker> createState() => _InvoiceMakerState();
}

class _InvoiceMakerState extends State<InvoiceMaker> {
  final List<InvoiceItem> _invoiceItems = [];

  void _addItem(InvoiceItem newItem) {
    setState(() {
      final existingIndex =
          _invoiceItems.indexWhere((item) => item.key == newItem.key);
      if (existingIndex >= 0) {
        _invoiceItems[existingIndex].quantity++;
      } else {
        _invoiceItems.add(newItem);
      }
    });
  }

  void _setQuantity(int index, int newQty) {
    if (newQty < 1) return;
    setState(() {
      _invoiceItems[index].quantity = newQty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: ItemListScreen(
            items: _invoiceItems,
            onSaleToggled: (index) {
              setState(() {
                _invoiceItems[index].isSale = !_invoiceItems[index].isSale;
              });
            },
            onQuantityChanged: _setQuantity,
          ),
        ),

        // Brand buttons — row 1
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyButton(
                myButtonListLink: 'Tielke Sandwich',
                myButtonText: 'Tielke',
                myColor: const Color.fromARGB(255, 121, 89, 0),
                pricingCategory: widget.pricingCategory,
                onFlavorSelected: _addItem,
                imagePath: 'lib/assets/images/Tielkes.png',
              ),
              MyButton(
                myButtonListLink: 'Shelton Pizza',
                myButtonText: 'Shelton\nPizza',
                myColor: const Color.fromARGB(255, 255, 0, 0),
                pricingCategory: widget.pricingCategory,
                onFlavorSelected: _addItem,
                imagePath: 'lib/assets/images/SheltonIcon.png',
              ),
              Expanded(
                child: Column(
                  children: [
                    MyButton(
                      myButtonListLink: 'Duluth Sausage Meat & Cheese',
                      myButtonText: 'DSC',
                      myColor: const Color.fromARGB(255, 232, 139, 0),
                      pricingCategory: widget.pricingCategory,
                      onFlavorSelected: _addItem,
                    ),
                    MyButton(
                      myButtonListLink: 'Cloverdale Hot Dog',
                      myButtonText: 'Hot Dog',
                      myColor: Colors.redAccent.shade100,
                      pricingCategory: widget.pricingCategory,
                      onFlavorSelected: _addItem,
                      imagePath: 'lib/assets/images/HotDog.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Brand buttons — row 2
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyButton(
                myButtonListLink: 'Stokke Meat Stick',
                myButtonText: 'Stokke\nMeat Stick',
                myColor: Colors.yellow.shade600,
                pricingCategory: widget.pricingCategory,
                onFlavorSelected: _addItem,
              ),
              MyButton(
                myButtonListLink: 'Stokke Pizza',
                myButtonText: 'Stokke\nPizza',
                myColor: Colors.yellow.shade600,
                pricingCategory: widget.pricingCategory,
                onFlavorSelected: _addItem,
                imagePath: 'lib/assets/images/StokkesPizza3.png',
              ),
              MyButton(
                myButtonListLink: 'Stokke Brat',
                myButtonText: 'Stokke\nBrat',
                myColor: Colors.yellow.shade600,
                pricingCategory: widget.pricingCategory,
                onFlavorSelected: _addItem,
                imagePath: 'lib/assets/images/Brats.png',
              ),
            ],
          ),
        ),

        Flexible(flex: 1, child: Container()),
      ],
    );
  }
}

class ItemListScreen extends StatelessWidget {
  final List<InvoiceItem> items;
  final void Function(int index) onSaleToggled;
  final void Function(int index, int newQuantity) onQuantityChanged;

  const ItemListScreen({
    super.key,
    required this.items,
    required this.onSaleToggled,
    required this.onQuantityChanged,
  });

  Future<void> _showQuantityDialog(
      BuildContext context, int index, int currentQty) async {
    final controller = TextEditingController(text: currentQty.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Quantity'),
          onSubmitted: (value) {
            final qty = int.tryParse(value) ?? currentQty;
            if (qty >= 1) onQuantityChanged(index, qty);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(controller.text) ?? currentQty;
              if (qty >= 1) onQuantityChanged(index, qty);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.amber, width: 2.0),
      ),
      child: items.isEmpty
          ? const Center(child: Text('No items yet.', style: TextStyle(fontSize: 18)))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: Colors.grey.shade700),
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Line 1: Brand  Product  Flavor ──────────────────
                      Row(
                        children: [
                          Text(
                            item.brand,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.product,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.flavor,
                              style: const TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // ── Line 2: [SALE/REG] ── [$price] [−][qty][+] [$total] ──
                      Row(
                        children: [
                          // SALE/REG toggle on the far left — fixed width so
                          // it never shifts the right-side content
                          SizedBox(
                            width: 58,
                            child: item.salePrice != null
                                ? TextButton(
                                    onPressed: () => onSaleToggled(index),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      item.isSale ? 'SALE' : 'REG',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: item.isSale
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                  )
                                : null,
                          ),

                          // Push everything else to the right
                          const Spacer(),

                          // Price per unit
                          Text(
                            '\$${item.activePrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(width: 10),

                          // − button
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () =>
                                onQuantityChanged(index, item.quantity - 1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 30, minHeight: 30),
                          ),

                          // Quantity (tappable to type a number)
                          GestureDetector(
                            onTap: () => _showQuantityDialog(
                                context, index, item.quantity),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.amber),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),

                          // + button
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () =>
                                onQuantityChanged(index, item.quantity + 1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 30, minHeight: 30),
                          ),

                          const SizedBox(width: 6),

                          // Subtotal — fixed width so it always right-aligns
                          SizedBox(
                            width: 72,
                            child: Text(
                              '\$${item.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
