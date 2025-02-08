import 'package:cheez_bro/utils/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'edit_staff_screen.dart';
import 'add_staff_screen.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  StaffManagementScreenState createState() => StaffManagementScreenState();
}

class StaffManagementScreenState extends State<StaffManagementScreen> {
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
                  title: 'Staff Management',
                  targetWidget: AddStaffScreen(),
                  addIcon: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: DynamicDataTable(
                    searchQuery: searchQuery,
                    collectionName: 'staff',
                    columnNames: const [
                      'Staff ID',
                      'Staff Name',
                      'Staff Position',
                      'Staff Contact Number',
                      'Staff Email',
                      'Staff Address',
                      'Joining Date',
                    ],
                    columnFieldMapping: const {
                      'Staff ID': 'id',
                      'Staff Name': 'first_name',
                      'Staff Position': 'position',
                      'Staff Contact Number': 'mobile_number',
                      'Staff Email': 'email',
                      'Staff Address': 'address',
                      'Joining Date': 'joining_date',
                    },
                    targetWidget: (userId, userData) {
                      return EditStaffScreen(
                          staffId: userId, staffData: userData);
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
