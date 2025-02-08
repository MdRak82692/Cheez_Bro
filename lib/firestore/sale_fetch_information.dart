import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/summary_card.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<Map<String, double>> getTotalsByDate(
    String collection, String field, String dateField,
    {bool filterCompleted = false}) async {
  Map<String, double> totals = {};

  Query collectionQuery = firestore.collection(collection);

  // Apply status filter if fetching from 'orders'
  if (filterCompleted) {
    collectionQuery = collectionQuery.where('status', isEqualTo: 'Completed');
  }

  var snapshot = await collectionQuery.get();

  for (var doc in snapshot.docs) {
    final rawDate = (doc[dateField] as Timestamp?)?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy').format(rawDate);
    double value = (doc[field] ?? 0).toDouble();

    totals[formattedDate] = (totals[formattedDate] ?? 0.0) + value;
  }

  return totals;
}

class SalesDataWidget extends StatelessWidget {
  const SalesDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        getTotalsByDate('products', 'cost', 'time'),
        getTotalsByDate('orders', 'sale', 'time',
            filterCompleted: true), // ✅ Only Completed Orders
        getTotalsByDate('staffsalary', 'salary', 'time'),
      ]).then((results) {
        return {
          'productCost': results[0],
          'itemSale': results[1],
          'staffSalary': results[2],
        };
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final data = snapshot.data!;
        final productCostTotals =
            data['productCost']?.values.fold(0.0, (acc, item) => acc + item) ??
                0.0;

        final itemSaleTotals =
            data['itemSale']?.values.fold(0.0, (acc, item) => acc + item) ??
                0.0;

        final staffSalaryTotals =
            data['staffSalary']?.values.fold(0.0, (acc, item) => acc + item) ??
                0.0;

        final profitTotals =
            itemSaleTotals - productCostTotals - staffSalaryTotals;

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SummaryCard(
                    title: 'Total Product Cost', value: productCostTotals),
                const SizedBox(width: 20),
                SummaryCard(title: 'Total Item Sale', value: itemSaleTotals),
                const SizedBox(width: 20),
                SummaryCard(
                    title: 'Total Staff Salary', value: staffSalaryTotals),
                const SizedBox(width: 20),
                SummaryCard(title: 'Profit', value: profitTotals),
              ],
            ),
          ),
        );
      },
    );
  }
}
