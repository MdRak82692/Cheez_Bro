import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/password_strong.dart';
import '../../../utils/slider_bar.dart';
import 'category_management_screen.dart';

class EditCategoryScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditCategoryScreen(
      {super.key, required this.userId, required this.userData});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController categoryNameCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'categoryName': categoryNameCtrl,
    };

    loadInformation(
      id: widget.userId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'category',
      fieldsToSubmit: ['categoryName'],
    );
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
                          AddEditTitleSection(title: 'Update Category')
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
                          await updateInformation(
                            name1: '',
                            option1: '',
                            context: context,
                            targetWidget: const CategoryManagementScreen(),
                            controllers: {
                              'categoryName': categoryNameCtrl.text,
                            },
                            name: 'categoryName',
                            option: 'categoryName',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            passwordChecker: PasswordStrengthChecker(),
                            collectionName: 'category',
                            fieldsToSubmit: ['categoryName'],
                            addTimestamp: false,
                            userId: widget.userId,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Updated Category',
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
