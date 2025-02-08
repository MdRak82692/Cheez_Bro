import 'package:cheez_bro/components/button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/drop_down_button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import '../../../firestore/fetch_information.dart';
import '../../../utils/password_strong.dart';
import '../../../utils/slider_bar.dart';
import 'staff_salary_management_screen.dart';

class AddStaffSalaryScreen extends StatefulWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AddStaffSalaryScreen({super.key});

  @override
  State<AddStaffSalaryScreen> createState() => _AddStaffSalaryScreenState();
}

class _AddStaffSalaryScreenState extends State<AddStaffSalaryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController salaryCtrl = TextEditingController();
  final TextEditingController positionCtrl = TextEditingController();
  String? selectedStaff;

  List<Map<String, dynamic>> staffList = [];
  List<String> excludedStaffNames = [];
  bool isLoading = false;
  FetchInformation? fetchInformation;

  @override
  void initState() {
    super.initState();
    fetchInformation = FetchInformation(
      firestore: firestore,
      setState: setState,
    );

    fetchInformation!.fetchStaffData();
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
                          AddEditTitleSection(title: 'Add Staff Salary Details')
                        ],
                      ),
                      const SizedBox(height: 30),
                      DropDownButton(
                        label: 'Staff Name',
                        items: fetchInformation!.staffList
                            .map((staff) => staff['name'] as String)
                            .toList(),
                        selectedItem: selectedStaff,
                        icon: Icons.person,
                        onChanged: (value) {
                          setState(() {
                            selectedStaff = value;

                            final selectedStaffPosition = fetchInformation!
                                    .staffList
                                    .firstWhere((staff) =>
                                        staff['name'] == value)['position']
                                as String;
                            positionCtrl.text = selectedStaffPosition;
                          });
                        },
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
                          String staffName = selectedStaff ?? '';
                          String position = positionCtrl.text;
                          int salaryAmount = int.tryParse(salaryCtrl.text) ?? 0;

                          await addInformation(
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
                          );
                        },
                        isLoading: isLoading,
                        text: 'Add Salary Information',
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
