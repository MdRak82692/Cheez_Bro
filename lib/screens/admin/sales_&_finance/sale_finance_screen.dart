import 'package:cheez_bro/components/sale_data_table.dart';
import 'package:cheez_bro/components/sale_title.dart';
import 'package:cheez_bro/components/title_section.dart';
import 'package:cheez_bro/utils/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firestore/sale_fetch_information.dart';
import '../../../utils/slider_bar.dart';

class SaleFinanceScreen extends StatefulWidget {
  const SaleFinanceScreen({super.key});

  @override
  SaleFinanceScreenState createState() => SaleFinanceScreenState();
}

class SaleFinanceScreenState extends State<SaleFinanceScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Future<double> calculateTotal(String collection, String fieldName) async {
    double total = 0.0;
    final snapshot = await firestore.collection(collection).get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data[fieldName] is num) {
        total += data[fieldName].toDouble();
      }
    }
    return total;
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
                  title: 'Sale & Finance Management',
                  addIcon: false,
                ),
                const SalesDataWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SaleTitle(title: 'Product Cost'),
                        DynamicDataTable(
                          searchQuery: searchQuery,
                          collectionName: 'products',
                          columnNames: const [
                            'Product ID',
                            'Product Name',
                            'Total Price',
                            'Time'
                          ],
                          columnFieldMapping: const {
                            'Product ID': 'id',
                            'Product Name': 'productName',
                            'Total Price': 'cost',
                            'Time': 'time',
                          },
                          fieldName: 'time',
                        ),
                        FutureBuilder<double>(
                          future: calculateTotal('products', 'cost'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Item Sales'),
                        DynamicDataTable(
                          searchQuery: searchQuery,
                          collectionName: 'orders',
                          columnNames: const [
                            'Order ID',
                            'Item Name',
                            'Total Price',
                            'Time'
                          ],
                          columnFieldMapping: const {
                            'Order ID': 'id',
                            'Total Price': 'sale',
                            'Time': 'time',
                          },
                          fieldName: 'time',
                        ),
                        FutureBuilder<double>(
                          future: calculateTotal('orders', 'sale'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const SaleTitle(title: 'Staff Salary'),
                        DynamicDataTable(
                          searchQuery: searchQuery,
                          collectionName: 'staffsalary',
                          columnNames: const [
                            'Salary ID',
                            'Staff Name',
                            'Salary',
                            'Time'
                          ],
                          columnFieldMapping: const {
                            'Salary ID': 'id',
                            'Staff Name': 'staff_name',
                            'Salary': 'salary',
                            'Time': 'time',
                          },
                          fieldName: 'time',
                        ),
                        FutureBuilder<double>(
                          future: calculateTotal('staffsalary', 'salary'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
