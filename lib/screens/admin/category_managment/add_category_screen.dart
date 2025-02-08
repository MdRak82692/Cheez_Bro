import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/password_strong.dart';
import '../../../utils/slider_bar.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import 'category_management_screen.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController categoryNameCtrl = TextEditingController();

  bool isLoading = false;

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
                          AddEditTitleSection(title: 'Add New Category')
                        ],
                      ),
                      const SizedBox(height: 30),
                      InputField(
                          controller: categoryNameCtrl,
                          label: "Category Name",
                          icon: Icons.category),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPressed: () async {
                          await addInformation(
                            context: context,
                            name1: '',
                            option1: '',
                            targetWidget: const CategoryManagementScreen(),
                            controllers: {
                              'categoryName': categoryNameCtrl.text,
                            },
                            name: 'categoryName',
                            option: 'categoryName',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            collectionName: 'category',
                            fieldsToSubmit: ['categoryName'],
                            addTimestamp: true,
                            passwordChecker: PasswordStrengthChecker(),
                          );
                        },
                        isLoading: isLoading,
                        text: 'Add Category',
                      )
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
