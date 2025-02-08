import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/drop_down_button.dart';
import '../../../firestore/add_information.dart';
import '../../../firestore/fetch_information.dart';
import '../../../utils/password_strong.dart';
import '../../../utils/slider_bar.dart';
import 'staff_attendance_management_screen.dart';

class AddStaffAttendanceScreen extends StatefulWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AddStaffAttendanceScreen({super.key});

  @override
  AddStaffAttendanceScreenState createState() =>
      AddStaffAttendanceScreenState();
}

class AddStaffAttendanceScreenState extends State<AddStaffAttendanceScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? selectedStaff;
  List<String> staffList = [];
  List<String> alreadyMarked = [];
  bool isLoading = false;
  FetchInformation? fetchInformation;

  @override
  void initState() {
    super.initState();
    fetchInformation = FetchInformation(
      firestore: widget.firestore,
      setState: setState,
    );
    fetchInformation!.fetchStaffNames();
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
                          AddEditTitleSection(title: 'Add Staff Attendance')
                        ],
                      ),
                      const SizedBox(height: 30),
                      DropDownButton(
                        label: 'Select Staff',
                        items: fetchInformation!.staffList
                            .map((staff) => staff['name'] as String)
                            .toList(),
                        selectedItem: fetchInformation!.selectedStaff,
                        icon: Icons.person,
                        onChanged: (String? value) {
                          setState(() {
                            fetchInformation!.selectedStaff = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPressed: () async {
                          await addInformation(
                            name1: '',
                            option1: '',
                            context: context,
                            targetWidget:
                                const StaffAttendanceManagementScreen(),
                            controllers: {
                              'staff_name': fetchInformation!.selectedStaff,
                            },
                            name: '',
                            option: '',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            passwordChecker: PasswordStrengthChecker(),
                            collectionName: 'staffattendance',
                            fieldsToSubmit: [
                              'staff_name',
                            ],
                            addTimestamp: true,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Mark Attendance',
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
