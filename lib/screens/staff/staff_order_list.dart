import 'package:cheez_bro/components/title_section.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/order_data_table.dart';
import '../../utils/search.dart';
import '../login_page.dart';
import 'add_order_list.dart';
import 'edit_order_list.dart';

class StaffOrderList extends StatefulWidget {
  const StaffOrderList({super.key});

  @override
  StaffOrderListState createState() => StaffOrderListState();
}

class StaffOrderListState extends State<StaffOrderList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
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
