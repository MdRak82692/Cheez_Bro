import 'package:cheez_bro/utils/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../function/delete_functions.dart';
import '../utils/text.dart';

class DynamicDataTable extends StatefulWidget {
  final Widget Function(String userId, Map<String, dynamic> userData)
      targetWidget;

  final String searchQuery;
  final String collectionName;
  final List<String> columnNames;
  final Map<String, dynamic> columnFieldMapping;

  const DynamicDataTable({
    super.key,
    required this.targetWidget,
    required this.searchQuery,
    required this.collectionName,
    required this.columnNames,
    required this.columnFieldMapping,
  });

  @override
  DynamicDataTableState createState() => DynamicDataTableState();
}

class DynamicDataTableState extends State<DynamicDataTable> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int? sortColumnIndex;
  bool sortAscending = true;

  Future<bool> isPaymentDone(String staffName) async {
    final currentDate = DateTime.now();
    final startOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final endOfMonth = DateTime(currentDate.year, currentDate.month + 1, 1);

    final snapshot = await firestore
        .collection('staffsalary')
        .where('staff_name', isEqualTo: staffName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        final time = (doc['time'] as Timestamp).toDate();
        if (time.isAfter(startOfMonth) && time.isBefore(endOfMonth)) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection(widget.collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No data found.",
              style: style(18, color: Colors.red),
            ),
          );
        }

        var records = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).where((record) {
          final query = widget.searchQuery.toLowerCase();

          return record.values.any((value) {
            if (value is Timestamp) {
              String formattedDate = formatDateTimestamp(value);
              return formattedDate.toLowerCase().contains(query);
            } else {
              return value.toString().toLowerCase().contains(query);
            }
          });
        }).toList();

        if (sortColumnIndex != null) {
          records.sort((a, b) {
            var fieldA =
                widget.columnFieldMapping[widget.columnNames[sortColumnIndex!]];
            var valueA = a[fieldA];
            var fieldB =
                widget.columnFieldMapping[widget.columnNames[sortColumnIndex!]];
            var valueB = b[fieldB];

            return sortAscending
                ? valueA.toString().compareTo(valueB.toString())
                : valueB.toString().compareTo(valueA.toString());
          });
        }

        return Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.green),
                horizontalMargin: 20,
                headingRowHeight: 50,
                sortColumnIndex: sortColumnIndex,
                sortAscending: sortAscending,
                columns: _buildDataColumns(),
                rows: records.map((record) => _buildDataRow(record)).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildDataColumns() {
    return widget.columnNames.map((name) {
      return DataColumn(
        label: Text(name, style: style1(16, color: Colors.black)),
        onSort: (columnIndex, ascending) {
          setState(() {
            sortColumnIndex = columnIndex;
            sortAscending = ascending;
          });
        },
      );
    }).toList()
      ..add(
        DataColumn(
          label: Text(
            'Actions',
            style: style1(16, color: Colors.black),
          ),
        ),
      );
  }

  DataRow _buildDataRow(Map<String, dynamic> record) {
    String staffName = record['staff_name'] ?? 'N/A';
    var salaryAmount = record['salary_amount'] ?? 0;

    return DataRow(
      color: WidgetStateProperty.all(Colors.lightGreen.shade100),
      cells: widget.columnNames.map((col) {
        var fieldName = widget.columnFieldMapping[col];
        var value = record[fieldName] ?? 'N/A';

        if (col == 'Staff Name') {
          var firstName = record['first_name'] ?? 'N/A';
          var lastName = record['last_name'] ?? '';
          value = '$firstName $lastName';
        }

        if (value is Timestamp) {
          value = formatDateTimestamp(value);
        }

        if (col == 'Payment Status') {
          return DataCell(
            FutureBuilder<bool>(
              future: isPaymentDone(staffName),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final isPaid = snapshot.data!;
                return isPaid
                    ? Text(
                        "Done",
                        style: style2(16, color: Colors.green),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.payment,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await firestore.collection('staffsalary').add({
                            'staff_name': staffName,
                            'salary': salaryAmount,
                            'time': FieldValue.serverTimestamp(),
                          }).then(
                            (value) {
                              if (!context.mounted) return;
                              showCustomDialog(context, 'Successful',
                                  'Salary paid successfully');
                              setState(() {});
                            },
                          ).catchError(
                            (error) {
                              if (!context.mounted) return;
                              showCustomDialog(
                                  context, 'Error', 'Error: $error');
                            },
                          );
                        },
                      );
              },
            ),
          );
        }

        return DataCell(
            Text(value.toString(), style: style2(16, color: Colors.black)));
      }).toList()
        ..add(
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    String userId = record['id'];
                    Map<String, dynamic> userData = record;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            widget.targetWidget(userId, userData),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    var userId = record['id'];
                    if (userId != null) {
                      deleteFunction(context, userId, widget.collectionName);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }

  String formatDateTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateFormat formatter = DateFormat('dd MMMM yyyy hh:mm a');
    return formatter.format(date);
  }
}
