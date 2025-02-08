import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/password_strong.dart';
import '../../../utils/slider_bar.dart';
import 'staff_salary_management_screen.dart';

class EditStaffSalaryScreen extends StatefulWidget {
  final String salaryId;
  final Map<String, dynamic> staffData;

  const EditStaffSalaryScreen(
      {super.key, required this.salaryId, required this.staffData});

  @override
  EditStaffSalaryScreenState createState() => EditStaffSalaryScreenState();
}

class EditStaffSalaryScreenState extends State<EditStaffSalaryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController staffNameCtrl = TextEditingController();
  final TextEditingController salaryCtrl = TextEditingController();
  final TextEditingController positionCtrl = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'staff_name': staffNameCtrl,
      'position': positionCtrl,
      'salary_amount': salaryCtrl,
    };

    loadInformation(
      id: widget.salaryId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'staffsalaryinformation',
      fieldsToSubmit: ['staff_name', 'position', 'salary_amount'],
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
                          AddEditTitleSection(
                              title: 'Edit Staff Salary Details')
                        ],
                      ),
                      const SizedBox(height: 30),
                      InputField(
                        controller: staffNameCtrl,
                        label: 'Staff Name',
                        icon: Icons.person,
                        readOnly: true,
                      ),
                      InputField(
                        controller: positionCtrl,
                        label: 'Staff Position',
                        icon: Icons.business_center,
                        readOnly: true,
                      ),
                      InputField(
                        controller: salaryCtrl,
                        label: 'Salary',
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPressed: () async {
                          String staffName = staffNameCtrl.text;
                          String position = positionCtrl.text;
                          int salaryAmount = int.tryParse(salaryCtrl.text) ?? 0;

                          await updateInformation(
                            name1: '',
                            option1: '',
                            context: context,
                            targetWidget: const StaffSalaryManagementScreen(),
                            controllers: {
                              'staff_name': staffName,
                              'position': position,
                              'salary_amount': salaryAmount,
                            },
                            name: '',
                            option: '',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            passwordChecker: PasswordStrengthChecker(),
                            collectionName: 'staffsalaryinformation',
                            fieldsToSubmit: [
                              'staff_name',
                              'position',
                              'salary_amount'
                            ],
                            addTimestamp: false,
                            userId: widget.salaryId,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Update Salary Information',
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
