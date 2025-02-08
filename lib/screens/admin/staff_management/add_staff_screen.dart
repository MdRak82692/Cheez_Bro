import 'package:cheez_bro/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import '../../../utils/password_strong.dart';
import '../../../utils/slider_bar.dart';
import 'staff_management_screen.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  AddStaffScreenState createState() => AddStaffScreenState();
}

class AddStaffScreenState extends State<AddStaffScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController lastNameCtrl = TextEditingController();
  TextEditingController positionCtrl = TextEditingController();
  TextEditingController mobileCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();
  TextEditingController joiningDateCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> selectJoiningDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onSurface: Colors.black,
            ),
            textTheme: TextTheme(
              bodySmall: style2(16, color: Colors.yellow),
              bodyLarge: style2(14, color: Colors.green),
              labelLarge: style2(14, color: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        joiningDateCtrl.text = DateFormat('dd MMMM yyyy').format(pickedDate);
      });
    }
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
                              title: 'Add New Staff Information')
                        ],
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              InputField(
                                controller: firstNameCtrl,
                                label: "Staff First Name",
                                icon: Icons.person,
                              ),
                              InputField(
                                controller: lastNameCtrl,
                                label: "Staff Last Name",
                                icon: Icons.person,
                              ),
                              InputField(
                                controller: positionCtrl,
                                label: "Staff Position",
                                icon: Icons.business_center,
                              ),
                              InputField(
                                controller: mobileCtrl,
                                label: "Contact Number",
                                icon: Icons.phone,
                              ),
                              InputField(
                                controller: emailCtrl,
                                label: "Email",
                                icon: Icons.email,
                              ),
                              InputField(
                                controller: addressCtrl,
                                label: "Staff Address",
                                icon: Icons.home,
                              ),
                              InputField(
                                controller: joiningDateCtrl,
                                label: "Staff Joining Date",
                                icon: Icons.calendar_today,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.date_range,
                                      color: Colors.blue),
                                  onPressed: () => selectJoiningDate(context),
                                ),
                                readOnly: true,
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                      CustomButton(
                        onPressed: () async {
                          await addInformation(
                            context: context,
                            targetWidget: const StaffManagementScreen(),
                            controllers: {
                              'first_name': firstNameCtrl.text,
                              'last_name': lastNameCtrl.text,
                              'position': positionCtrl.text,
                              'mobile_number': mobileCtrl.text,
                              'email': emailCtrl.text,
                              'address': addressCtrl.text,
                              'joining_date': joiningDateCtrl.text,
                            },
                            name: 'email',
                            option: 'email',
                            name1: 'mobile_number',
                            option1: 'mobile_number',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            passwordChecker: PasswordStrengthChecker(),
                            collectionName: 'staff',
                            fieldsToSubmit: [
                              'first_name',
                              'last_name',
                              'position',
                              'mobile_number',
                              'email',
                              'address',
                              'joining_date',
                            ],
                            addTimestamp: false,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Add Staff Information',
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
