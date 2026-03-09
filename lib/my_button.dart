import 'package:flutter/material.dart';
import 'package:northern_buttons/flavors.dart';
import 'package:northern_buttons/models/invoice_item.dart';
import 'package:google_fonts/google_fonts.dart';


// *** BUTTON TEXT ***
// This is the text that will be inside MyButton Widget (below)
class MyButtonText extends StatelessWidget {
  final String mytext;

  const MyButtonText({super.key, required this.mytext});

  @override
  Widget build(BuildContext context) {
    return Text(
      mytext,
      textAlign: TextAlign.center,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 255, 247, 255),
      ),
    );
  }
}


// *** MY BUTTON ***
class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.myColor,
    required this.myButtonText,
    required this.myButtonListLink,
    required this.pricingCategory,
    required this.onFlavorSelected,
    this.imagePath,
  });

  final Color myColor;
  final String myButtonText;
  final String myButtonListLink;   // brand+product label, e.g. "Stokke Pizza"
  final String pricingCategory;    // pricing tier for the selected store
  final void Function(InvoiceItem item) onFlavorSelected; // passed up to Brands
  final String? imagePath;         // optional image to replace the button text

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showFlavors(
              context: context,
              brandProduct: myButtonListLink,
              pricingCategory: pricingCategory,
              onFlavorSelected: onFlavorSelected,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: myColor,
                  width: 2.0,
                ),
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        imagePath!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(child: MyButtonText(mytext: myButtonText)),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
