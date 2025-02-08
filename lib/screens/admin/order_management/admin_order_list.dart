import 'package:cheez_bro/components/order_data_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../components/title_section.dart';
import '../../../utils/search.dart';
import '../../../utils/slider_bar.dart';
import 'add_order_list.dart';
import 'edit_order_list.dart';

class AdminOrderList extends StatefulWidget {
  const AdminOrderList({super.key});

  @override
  AdminOrderListState createState() => AdminOrderListState();
}

class AdminOrderListState extends State<AdminOrderList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  title: 'Order Management',
                  targetWidget: AddOrderList(),
                  addIcon: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: DynamicDataTable(
                    targetWidget: (userId, userData) {
                      return EditOrderList(
                          orderId: userId, orderData: userData);
                    },
                    searchQuery: searchQuery,
                    collectionName: 'orders',
                    columnNames: const [
                      'Total Price',
                      'Status',
                      'Payment',
                      'Delivery',
                      'Order Time',
                      'Finish Time',
                      'Total Time',
                    ],
                    columnFieldMapping: const {
                      'items': 'items',
                      'Delivery': 'deliveryType',
                      'Payment': 'Payment',
                      'Status': 'status',
                      'Order Time': 'time',
                      'Finish Time': 'doneTime',
                      'Total Price': 'sale',
                    },
                    fieldName: 'time',
                    itemNames: const [
                      'Order Type',
                      'Category',
                      'Item Name',
                      'Size',
                      'Quantity',
                      'Price Per Item',
                      'Item Price',
                    ],
                    itemFieldMapping: const {
                      'Order Type': 'orderType',
                      'Category': 'category',
                      'Item Name': 'itemName',
                      'Size': 'size',
                      'Quantity': 'quantity',
                      'Price Per Item': 'pricePerItem',
                      'Item Price': 'itemPrice',
                    },
                  ),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
