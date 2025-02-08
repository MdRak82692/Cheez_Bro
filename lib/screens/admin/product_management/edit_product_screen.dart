import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/drop_down_button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/password_strong.dart';
import '../../../utils/slider_bar.dart';
import 'product_management_screen.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductScreen(
      {super.key, required this.productId, required this.productData});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController productNameCtrl = TextEditingController();
  final TextEditingController quantityCtrl = TextEditingController();
  final TextEditingController pricePerProductCtrl = TextEditingController();
  final TextEditingController totalPriceCtrl = TextEditingController();
  bool isLoading = false;
  String? selectedUnit;

  final _passwordChecker = PasswordStrengthChecker();
  final List<String> units = ['kg', 'pocket', 'piece'];

  @override
  void initState() {
    super.initState();
    selectedUnit = widget.productData['unit'];
    Map<String, dynamic> controllers = {
      'productName': productNameCtrl,
      'quantity': quantityCtrl,
      'pricePerProduct': pricePerProductCtrl,
      'cost': totalPriceCtrl,
    };

    loadInformation(
      id: widget.productId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'products',
      fieldsToSubmit: [
        'productName',
        'quantity',
        'pricePerProduct',
        'cost',
        'unit'
      ],
    );
  }

  void updateTotalPrice() {
    final int quantity = int.tryParse(quantityCtrl.text) ?? 0;
    final int pricePerProduct = int.tryParse(pricePerProductCtrl.text) ?? 0;
    final int totalPrice = quantity * pricePerProduct;

    setState(() {
      totalPriceCtrl.text = totalPrice.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(isSidebarExpanded: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AddEditTitleSection(title: 'Update Product Details')
                        ],
                      ),
                      const SizedBox(height: 30),
                      InputField(
                        controller: productNameCtrl,
                        label: "Product Name",
                        icon: Icons.label,
                      ),
                      InputField(
                        controller: quantityCtrl,
                        label: "Quantity",
                        icon: Icons.archive,
                        onChanged: (value) => updateTotalPrice(),
                      ),
                      InputField(
                        controller: pricePerProductCtrl,
                        label: "Price Per Product",
                        icon: Icons.attach_money,
                        onChanged: (value) => updateTotalPrice(),
                      ),
                      InputField(
                        controller: totalPriceCtrl,
                        label: "Total Price",
                        icon: Icons.receipt,
                        readOnly: true,
                      ),
                      DropDownButton(
                        label: "Units",
                        items: units,
                        icon: Icons.check_box,
                        selectedItem: selectedUnit,
                        onChanged: (String? value) {
                          setState(() {
                            selectedUnit = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPressed: () async {
                          int quantity = int.tryParse(quantityCtrl.text) ?? 0;
                          int pricePerProduct =
                              int.tryParse(pricePerProductCtrl.text) ?? 0;
                          int totalPrice =
                              int.tryParse(totalPriceCtrl.text) ?? 0;

                          await updateInformation(
                            name1: '',
                            option1: '',
                            context: context,
                            targetWidget: const ProductManagementScreen(),
                            controllers: {
                              'productName': productNameCtrl.text,
                              'quantity': quantity,
                              'pricePerProduct': pricePerProduct,
                              'cost': totalPrice,
                              'unit': selectedUnit,
                            },
                            name: '',
                            option: '',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            passwordChecker: _passwordChecker,
                            collectionName: 'products',
                            fieldsToSubmit: [
                              'productName',
                              'quantity',
                              'pricePerProduct',
                              'cost',
                              'unit',
                            ],
                            addTimestamp: true,
                            userId: widget.productId,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Update Product Information',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
