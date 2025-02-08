import 'package:cheez_bro/components/admin_data_table.dart';
import 'package:cheez_bro/components/title_section.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import 'add_admin_profile.dart';
import 'edit_admin_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String? primaryAdminUID;
  String? primaryAdminEmail;
  String? primaryAdminCreationDate;
  String passwordDisplay = 'N/A';
  bool isLoading = true;
  List<Map<String, dynamic>> admins = [];

  @override
  void initState() {
    super.initState();
    getPrimaryAdminDetails();
  }

  void getPrimaryAdminDetails() async {
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        primaryAdminUID = user.uid;
        primaryAdminEmail = user.email ?? 'N/A';

        // Format the creation time
        if (user.metadata.creationTime != null) {
          primaryAdminCreationDate = DateFormat('dd MMMM yyyy hh:mm a')
              .format(user.metadata.creationTime!);
        } else {
          primaryAdminCreationDate = 'N/A';
        }

        admins.insert(0, {
          'id': primaryAdminUID,
          'name': 'Primary Admin',
          'email': primaryAdminEmail,
          'time': primaryAdminCreationDate,
          'password': passwordDisplay
        });
      });
    }
  }

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
                  title: 'Admin Profile',
                  targetWidget: AddAdminProfile(),
                  addIcon: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: DynamicDataTable(
                    searchQuery: searchQuery,
                    collectionName: 'admin',
                    columnNames: const [
                      'Admin UID',
                      'Admin Name',
                      'Email',
                      'Created Date & Time',
                      'Password'
                    ],
                    columnFieldMapping: const {
                      'Admin UID': 'id',
                      'Admin Name': 'name',
                      'Email': 'email',
                      'Created Date & Time': 'time',
                      'Password': 'password',
                    },
                    items: admins,
                    targetWidget: (userId, userData) {
                      return EditAdminProfile(
                          adminId: userId, adminData: userData);
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
