import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/separate_data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import 'add_staff_attendance_screen.dart';

class StaffAttendanceManagementScreen extends StatefulWidget {
  const StaffAttendanceManagementScreen({super.key});

  @override
  StaffAttendanceManagementScreenState createState() =>
      StaffAttendanceManagementScreenState();
}

class StaffAttendanceManagementScreenState
    extends State<StaffAttendanceManagementScreen> {
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
                  title: 'Staff Attendance Management',
                  targetWidget: AddStaffAttendanceScreen(),
                  addIcon: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: DynamicDataTable(
                    staffAttendance: true,
                    searchQuery: searchQuery,
                    collectionName: 'staffattendance',
                    columnNames: const [
                      'Attendance ID',
                      'Staff Name',
                      'Check In',
                      'Check Out',
                      'Total Work Hours',
                    ],
                    columnFieldMapping: const {
                      'Attendance ID': 'id',
                      'Staff Name': 'staff_name',
                      'Check In': 'time',
                      'Check Out': 'outtime',
                    },
                    targetWidget: (userId, userData) {
                      return Container();
                    },
                    fieldName: 'time',
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
