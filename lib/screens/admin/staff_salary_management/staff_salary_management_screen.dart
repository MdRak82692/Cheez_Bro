import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'package:cheez_bro/utils/search.dart';
import 'add_staff_salary_screen.dart';
import 'edit_staff_salary_screen.dart';

class StaffSalaryManagementScreen extends StatefulWidget {
  const StaffSalaryManagementScreen({super.key});

  @override
  StaffSalaryManagementScreenState createState() =>
      StaffSalaryManagementScreenState();
}

class StaffSalaryManagementScreenState
    extends State<StaffSalaryManagementScreen> {
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
                TitleSection(
                  title: 'Staff Management',
                  targetWidget: AddStaffSalaryScreen(),
                  addIcon: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: DynamicDataTable(
                    searchQuery: searchQuery,
                    collectionName: 'staffsalaryinformation',
                    columnNames: const [
                      'Salary ID',
                      'Staff Name ',
                      'Staff Position',
                      'Salary Amount',
                      'Payment Status'
                    ],
                    columnFieldMapping: const {
                      'Salary ID': 'id',
                      'Staff Name ': 'staff_name',
                      'Staff Position': 'position',
                      'Salary Amount': 'salary_amount',
                    },
                    targetWidget: (userId, userData) {
                      return EditStaffSalaryScreen(
                          salaryId: userId, staffData: userData);
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
