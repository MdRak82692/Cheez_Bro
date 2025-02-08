import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../components/data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import 'edit_category_screen.dart';
import '../../../utils/search.dart';
import 'add_category_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  CategoryManagementScreenState createState() =>
      CategoryManagementScreenState();
}

class CategoryManagementScreenState extends State<CategoryManagementScreen> {
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
                  title: 'Category Management',
                  targetWidget: AddCategoryScreen(),
                  addIcon: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: DynamicDataTable(
                    searchQuery: searchQuery,
                    collectionName: 'category',
                    columnNames: const [
                      'Category ID',
                      'Category Name',
                    ],
                    columnFieldMapping: const {
                      'Category ID': 'id',
                      'Category Name': 'categoryName',
                    },
                    targetWidget: (userId, userData) {
                      return EditCategoryScreen(
                          userId: userId, userData: userData);
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
