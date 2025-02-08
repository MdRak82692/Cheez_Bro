import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/add_information.dart';
import '../../../utils/slider_bar.dart';
import '../../../utils/password_strong.dart';
import 'user_management_screen.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final firestore = FirebaseFirestore.instance;
  final _userNameCtrl = TextEditingController();
  final _branchNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool isLoading = false;
  String _passwordStrength = '';
  final _passwordChecker = PasswordStrengthChecker();

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
                        children: [AddEditTitleSection(title: 'Add New User')],
                      ),
                      const SizedBox(height: 30),
                      InputField(
                          controller: _userNameCtrl,
                          label: "User Name",
                          icon: Icons.person),
                      InputField(
                          controller: _branchNameCtrl,
                          label: "Branch Name",
                          icon: Icons.store),
                      InputField(
                          controller: _emailCtrl,
                          label: "Email",
                          icon: Icons.email),
                      InputField(
                          controller: _passwordCtrl,
                          label: "Password",
                          icon: Icons.lock,
                          obscure: true,
                          onChanged: (text) =>
                              _passwordChecker.isPasswordStrong(
                                  text,
                                  (s) =>
                                      setState(() => _passwordStrength = s))),
                      buildPasswordStrengthIndicator(_passwordStrength),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPressed: () async {
                          await addInformation(
                            name1: '',
                            option1: '',
                            context: context,
                            targetWidget: const UserManagementScreen(),
                            controllers: {
                              'userName': _userNameCtrl.text,
                              'branchName': _branchNameCtrl.text,
                              'email': _emailCtrl.text,
                              'password': _passwordCtrl.text,
                            },
                            name: 'email',
                            option: 'email',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            passwordChecker: _passwordChecker,
                            collectionName: 'users',
                            fieldsToSubmit: [
                              'userName',
                              'branchName',
                              'email',
                              'password'
                            ],
                            addTimestamp: true,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Add User Information',
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
