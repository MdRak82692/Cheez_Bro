import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../components/add_edit_title_section.dart';
import '../../../components/button.dart';
import '../../../components/input_field.dart';
import '../../../firestore/load_informaion.dart';
import '../../../firestore/update_information.dart';
import '../../../utils/slider_bar.dart';
import 'admin_profile_page.dart';
import '../../../utils/password_strong.dart';

class EditAdminProfile extends StatefulWidget {
  final String adminId;
  final Map<String, dynamic> adminData;

  const EditAdminProfile({
    super.key,
    required this.adminId,
    required this.adminData,
  });

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController adminNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool isLoading = false;
  String _passwordStrength = '';
  final _passwordChecker = PasswordStrengthChecker();

  @override
  void initState() {
    super.initState();
    Map<String, TextEditingController> controllers = {
      'name': adminNameCtrl,
      'email': emailCtrl,
      'password': passwordCtrl,
    };

    loadInformation(
      id: widget.adminId,
      context: context,
      controllers: controllers,
      firestore: FirebaseFirestore.instance,
      isLoading: true,
      setState: setState,
      collectionName: 'admin',
      fieldsToSubmit: ['name', 'email', 'password'],
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
                        children: [AddEditTitleSection(title: 'Update Admin')],
                      ),
                      const SizedBox(height: 30),
                      InputField(
                          controller: adminNameCtrl,
                          label: "Admin Name",
                          icon: Icons.person),
                      InputField(
                          controller: emailCtrl,
                          label: "Email",
                          icon: Icons.email),
                      InputField(
                          controller: passwordCtrl,
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
                            context: context,
                            targetWidget: const ProfilePage(),
                            controllers: {
                              'name': adminNameCtrl.text,
                              'email': emailCtrl.text,
                              'password': passwordCtrl.text,
                            },
                            name: 'email',
                            option: 'email',
                            firestore: firestore,
                            isLoading: isLoading,
                            setState: setState,
                            passwordChecker: _passwordChecker,
                            collectionName: 'admin',
                            fieldsToSubmit: ['name', 'email', 'password'],
                            addTimestamp: false,
                            userId: widget.adminId,
                            name1: '',
                            option1: '',
                          );
                        },
                        isLoading: isLoading,
                        text: 'Updated Admin Information',
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
