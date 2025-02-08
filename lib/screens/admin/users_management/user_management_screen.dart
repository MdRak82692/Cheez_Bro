import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../components/data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';
import '../../../utils/search.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  UserManagementScreenState createState() => UserManagementScreenState();
}

class UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          const BuildSidebar(isSidebarExpanded: true),
          Expanded(
            child: Column(
              children: [
                HeaderWithSearch(
                  searchQuery: searchQuery,
                  searchController: searchController,
                  onSearchChanged: (value) =>
                      setState(() => searchQuery = value),
                ),
                const TitleSection(
                  title: 'Users Management',
                  targetWidget: AddUserScreen(),
                  addIcon: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: DynamicDataTable(
                    searchQuery: searchQuery,
                    collectionName: 'users',
                    columnNames: const [
                      'User UID',
                      'User Name',
                      'Branch Name',
                      'Email',
                      'Created Date & Time',
                      'Signed In Date & Time',
                      'Password'
                    ],
                    columnFieldMapping: const {
                      'User UID': 'id',
                      'User Name': 'userName',
                      'Branch Name': 'branchName',
                      'Email': 'email',
                      'Created Date & Time': 'time',
                      'Signed In Date & Time': 'lastSignedIn',
                      'Password': 'password',
                    },
                    targetWidget: (userId, userData) {
                      return EditUserScreen(userId: userId, userData: userData);
                    },
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
