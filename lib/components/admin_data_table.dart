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
  final Map<String, String> columnFieldMapping;
  final List<Map<String, dynamic>> items;

  const DynamicDataTable({
    super.key,
    required this.targetWidget,
    required this.searchQuery,
    required this.collectionName,
    required this.columnNames,
    required this.columnFieldMapping,
    required this.items,
  });

  @override
  DynamicDataTableState createState() => DynamicDataTableState();
}

class DynamicDataTableState extends State<DynamicDataTable> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int? sortColumnIndex;
  bool sortAscending = true;

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

        // Add the primary admin at the top of the list if present
        if (widget.items.isNotEmpty) {
          records.insert(0, widget.items.first);
        }

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
    // Check if the record is the primary admin
    bool isPrimaryAdmin = record['id'] == widget.items.first['id'];

    return DataRow(
      color: WidgetStateProperty.all(Colors.lightGreen.shade100),
      cells: widget.columnNames.map((col) {
        var fieldName = widget.columnFieldMapping[col];
        var value = record[fieldName] ?? 'N/A';

        if (value is Timestamp) {
          value = formatDateTimestamp(value);
        }

        return DataCell(
            Text(value.toString(), style: style2(16, color: Colors.black)));
      }).toList()
        ..add(
          DataCell(
            isPrimaryAdmin
                ? Container()
                : Row(
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
                            deleteFunction(
                                context, userId, widget.collectionName);
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
