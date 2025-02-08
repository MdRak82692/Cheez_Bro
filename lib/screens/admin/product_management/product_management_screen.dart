import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/separate_data_table.dart';
import '../../../components/title_section.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ProductManagementScreenState createState() => ProductManagementScreenState();
}

class ProductManagementScreenState extends State<ProductManagementScreen> {
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
                  title: 'Product Management',
                  targetWidget: AddProductScreen(),
                  addIcon: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: DynamicDataTable(
                    searchQuery: searchQuery,
                    collectionName: 'products',
                    columnNames: const [
                      'Product ID',
                      'Product Name',
                      'Quantity',
                      'Price Per Product',
                      'Total Price',
                      'Time',
                    ],
                    columnFieldMapping: const {
                      'Product ID': 'id',
                      'Product Name': 'productName',
                      'Quantity': 'quantity',
                      'Price Per Product': 'pricePerProduct',
                      'Total Price': 'cost',
                      'Time': 'time',
                    },
                    targetWidget: (userId, userData) {
                      return EditProductScreen(
                          productId: userId, productData: userData);
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
