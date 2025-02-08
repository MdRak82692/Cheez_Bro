import 'package:cheez_bro/firestore/update_information.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../utils/slider_bar.dart';
import 'user_management_screen.dart';
import '../../../utils/password_strong.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditUserScreen(
      {super.key, required this.userId, required this.userData});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController _userNameCtrl = TextEditingController();
  final TextEditingController _branchNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool isLoading = false;
  String _passwordStrength = '';
  final _passwordChecker = PasswordStrengthChecker();

  final PasswordStrengthChecker passwordChecker = PasswordStrengthChecker();

  @override
  void initState() {
    super.initState();

    Map<String, TextEditingController> controllers = {
      'userName': _userNameCtrl,
      'branchName': _branchNameCtrl,
      'email': _emailCtrl,
      'password': _passwordCtrl,
    };

    loadInformation(
      id: widget.userId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'users',
      fieldsToSubmit: ['userName', 'branchName', 'email', 'password'],
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
                        children: [AddEditTitleSection(title: 'Update User')],
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
                          await updateInformation(
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
                            addTimestamp: false,
                            userId: widget.userId,
                          );
                        },
                        isLoading: isLoading,
                        text: 'Updated User Information',
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
