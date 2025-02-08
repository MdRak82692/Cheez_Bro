import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import '../../../utils/password_strong.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/drop_down_button.dart';
import 'menu_management_screen.dart';
import '../../../firestore/fetch_information.dart';

class AddMenuScreen extends StatefulWidget {
  const AddMenuScreen({super.key});

  @override
  State<AddMenuScreen> createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
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
    fetchInformation!.fetchCategories();
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
                          AddEditTitleSection(title: 'Add Menu Item Details')
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
                          await addInformation(
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
                            addTimestamp: false,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Add Menu Item',
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
