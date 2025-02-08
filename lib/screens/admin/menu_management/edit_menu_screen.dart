import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/drop_down_button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/fetch_information.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/password_strong.dart';
import '../../../utils/slider_bar.dart';
import 'menu_management_screen.dart';

class EditMenuScreen extends StatefulWidget {
  final String menuItemId;
  final Map<String, dynamic> menuData;

  const EditMenuScreen({
    super.key,
    required this.menuItemId,
    required this.menuData,
  });

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController itemNameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  bool isLoading = false;
  FetchInformation? fetchInformation;

  @override
  void initState() {
    super.initState();
    fetchInformation = FetchInformation(
      firestore: firestore,
      setState: setState,
    );
    fetchInformation!.fetchCategories().then((_) {
      setState(() {
        fetchInformation!.selectedCategory = widget.menuData['categoryName'];
        fetchInformation!.updateSizes(widget.menuData['categoryName']);
        fetchInformation!.selectedSize = widget.menuData['size'];
      });
    });

    itemNameCtrl.text = widget.menuData['itemName'];
    priceCtrl.text = widget.menuData['price'];
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
                          AddEditTitleSection(title: 'Edit Menu Item Details')
                        ],
                      ),
                      const SizedBox(height: 30),
                      DropDownButton(
                        label: 'Category',
                        items: fetchInformation!.categories,
                        selectedItem: fetchInformation!.selectedCategory,
                        icon: Icons.category,
                        onChanged: (value) =>
                            fetchInformation!.updateSizes(value!),
                      ),
                      if (fetchInformation!.sizes.isNotEmpty)
                        DropDownButton(
                          label: 'Size',
                          items: fetchInformation!.sizes,
                          selectedItem: fetchInformation!.selectedSize,
                          icon: Icons.straighten,
                          onChanged: (value) => setState(
                              () => fetchInformation!.selectedSize = value!),
                        ),
                      InputField(
                        controller: itemNameCtrl,
                        label: "Item Name",
                        icon: Icons.label,
                      ),
                      InputField(
                        controller: priceCtrl,
                        label: "Price",
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPressed: () async {
                          await updateInformation(
                            name1: '',
                            option1: '',
                            context: context,
                            targetWidget: const MenuManagementScreen(),
                            controllers: {
                              'categoryName':
                                  fetchInformation!.selectedCategory,
                              'itemName': itemNameCtrl.text,
                              'price': priceCtrl.text,
                              'size': fetchInformation!.selectedSize,
                            },
                            name: '',
                            option: '',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            passwordChecker: PasswordStrengthChecker(),
                            collectionName: 'menu',
                            fieldsToSubmit: [
                              'categoryName',
                              'itemName',
                              'price',
                              'size'
                            ],
                            addTimestamp: true,
                            userId: widget.menuItemId,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Update Menu Item',
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
