import 'package:cheez_bro/components/title_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/separate_data_table.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import 'add_menu_screen.dart';
import 'edit_menu_screen.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  MenuManagementScreenState createState() => MenuManagementScreenState();
}

class MenuManagementScreenState extends State<MenuManagementScreen> {
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
                  title: 'Menu Management',
                  targetWidget: AddMenuScreen(),
                  addIcon: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: DynamicDataTable(
                    searchQuery: searchQuery,
                    collectionName: 'menu',
                    columnNames: const [
                      'Item ID',
                      'Item Name',
                      'Price',
                      'Size'
                    ],
                    columnFieldMapping: const {
                      'Item ID': 'id',
                      'Item Name': 'itemName',
                      'Price': 'price',
                      'Size': 'size',
                    },
                    targetWidget: (userId, userData) {
                      return EditMenuScreen(
                          menuItemId: userId, menuData: userData);
                    },
                    fieldName: 'categoryName',
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
