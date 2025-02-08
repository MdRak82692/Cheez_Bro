import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/text.dart';

class DynamicDataTable extends StatefulWidget {
  final Widget Function(String userId, Map<String, dynamic> userData)
      targetWidget;
  final String searchQuery;
  final String collectionName;
  final List<String> columnNames;
  final Map<String, dynamic> columnFieldMapping;
  final String fieldName;
  final List<String> itemNames;
  final Map<String, dynamic> itemFieldMapping;

  const DynamicDataTable({
    super.key,
    required this.targetWidget,
    required this.searchQuery,
    required this.collectionName,
    required this.columnNames,
    required this.columnFieldMapping,
    required this.fieldName,
    required this.itemNames,
    required this.itemFieldMapping,
  });

  @override
  DynamicDataTableState createState() => DynamicDataTableState();
}

class DynamicDataTableState extends State<DynamicDataTable> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int? sortColumnIndex;
  bool sortAscending = false;

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
            'items': data['items'] ?? [],
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

        var groupedRecords = groupRecordsByDate(records);

        if (sortColumnIndex != null) {
          groupedRecords.forEach((date, records) {
            records.sort((a, b) {
              var fieldA = widget
                  .columnFieldMapping[widget.columnNames[sortColumnIndex!]];
              var valueA = a[fieldA];
              var fieldB = widget
                  .columnFieldMapping[widget.columnNames[sortColumnIndex!]];
              var valueB = b[fieldB];

              return sortAscending
                  ? valueA.toString().compareTo(valueB.toString())
                  : valueB.toString().compareTo(valueA.toString());
            });
          });
        }

        if (sortColumnIndex != null) {
          groupedRecords.forEach((date, records) {
            records.sort((a, b) {
              var fieldA =
                  widget.columnFieldMapping[widget.itemNames[sortColumnIndex!]];
              var valueA = a[fieldA];
              var fieldB =
                  widget.columnFieldMapping[widget.itemNames[sortColumnIndex!]];
              var valueB = b[fieldB];

              return sortAscending
                  ? valueA.toString().compareTo(valueB.toString())
                  : valueB.toString().compareTo(valueA.toString());
            });
          });
        }

        return Column(
          children: groupedRecords.keys.map((date) {
            var recordsForDate = groupedRecords[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 404.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(date,
                        style: style2(20, color: Colors.blue.shade800)),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
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
                        columns: buildDataColumns(),
                        rows: recordsForDate
                            .map((doc) => buildDataRows(doc))
                            .expand((rows) => rows)
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Map<String, List<Map<String, dynamic>>> groupRecordsByDate(
      List<Map<String, dynamic>> records) {
    Map<String, List<Map<String, dynamic>>> groupedRecords = {};

    for (var record in records) {
      var fieldValue = record[widget.fieldName];

      if (fieldValue is Timestamp) {
        var formattedDate = formatDatestamp(fieldValue);
        if (!groupedRecords.containsKey(formattedDate)) {
          groupedRecords[formattedDate] = [];
        }
        groupedRecords[formattedDate]!.add(record);
      } else if (fieldValue != null) {
        String fieldValueString = fieldValue.toString();
        if (!groupedRecords.containsKey(fieldValueString)) {
          groupedRecords[fieldValueString] = [];
        }
        groupedRecords[fieldValueString]!.add(record);
      }
    }

    var sortedGroupedRecords = Map.fromEntries(
      groupedRecords.entries.toList()
        ..sort((a, b) {
          if (a.key.contains(RegExp(r'\d{2} \w+ \d{4}'))) {
            var dateA = formatDateToDateTime(a.key);
            var dateB = formatDateToDateTime(b.key);
            return dateB.compareTo(dateA);
          } else {
            return a.key.compareTo(b.key);
          }
        }),
    );

    return sortedGroupedRecords;
  }

  DateTime formatDateToDateTime(String formattedDate) {
    final DateFormat formatter = DateFormat('dd MMMM yyyy');
    try {
      return formatter.parse(formattedDate);
    } catch (e) {
      rethrow;
    }
  }

  List<DataColumn> buildDataColumns() {
    List<String> newColumnNames = [
      'Order ID',
      ...widget.itemNames,
      ...widget.columnNames
    ];

    return newColumnNames.map((name) {
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
          label: Text('Actions', style: style1(16, color: Colors.black)),
        ),
      );
  }

  List<DataRow> buildDataRows(Map<String, dynamic> record) {
    var checkInTime = record['time'];
    var checkOutTime = record['doneTime'];
    String totalWorkHours = 'N/A';

    if (checkInTime is Timestamp && checkOutTime is Timestamp) {
      Duration difference =
          checkOutTime.toDate().difference(checkInTime.toDate());
      int hours = difference.inHours;
      int minutes = difference.inMinutes.remainder(60);
      int seconds = difference.inSeconds.remainder(60);
      totalWorkHours = "${hours}h ${minutes}m ${seconds}s";
    }

    List<DataRow> rows = [];

    List<dynamic> items = record['items'] is List ? record['items'] : [];

    if (items.isEmpty) {
      rows.add(createDataRow(record, totalWorkHours, null, isFirstRow: true));
    } else {
      for (var i = 0; i < items.length; i++) {
        rows.add(createDataRow(record, totalWorkHours, items[i],
            isFirstRow: (i == 0)));
      }
    }

    return rows;
  }

  DataRow createDataRow(
      Map<String, dynamic> record, String totalWorkHours, dynamic item,
      {required bool isFirstRow}) {
    List<DataCell> cells = [];

    if (isFirstRow) {
      cells.add(DataCell(Text(record['id']?.toString() ?? 'N/A',
          style: style2(16, color: Colors.black))));
    } else {
      cells.add(const DataCell(Text('')));
    }

    for (var itemName in widget.itemNames) {
      var itemValue = item != null
          ? (item[widget.itemFieldMapping[itemName]] ?? 'N/A')
          : 'N/A';

      cells.add(DataCell(
          Text(itemValue.toString(), style: style2(16, color: Colors.black))));
    }

    if (isFirstRow) {
      for (var col in widget.columnNames) {
        var fieldName = widget.columnFieldMapping[col];
        var value = record[fieldName] ?? 'N/A';

        if (col == 'Total Time') {
          value = totalWorkHours;
        }

        // Ensure the value is a string
        if (value is Timestamp) {
          value = formatTimestamp(value);
        } else if (value is int || value is double) {
          value = value.toString();
        }

        if (col == 'Payment') {
          if (value == 'Unpaid') {
            cells.add(
              DataCell(
                Row(
                  children: [
                    Text("Unpaid", style: style2(16, color: Colors.red)),
                    IconButton(
                      icon: const Icon(Icons.attach_money, color: Colors.green),
                      onPressed: () async {
                        String orderId = record['id'];
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(orderId)
                            .update({'Payment': 'Paid'});
                      },
                    ),
                  ],
                ),
              ),
            );
            continue;
          } else {
            cells.add(
                DataCell(Text("Paid", style: style2(16, color: Colors.green))));
            continue;
          }
        }

        if (col == 'Status') {
          if (value == 'Pending') {
            cells.add(
              DataCell(
                Row(
                  children: [
                    Text("Pending", style: style2(16, color: Colors.blue)),
                    if (record['Payment'] != 'Unpaid')
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          String orderId = record['id'];
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({
                            'status': 'Completed',
                            'doneTime': FieldValue.serverTimestamp(),
                          });
                        },
                      ),
                    if (record['Payment'] != 'Unpaid')
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          String orderId = record['id'];
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({
                            'status': 'Cancelled',
                            'doneTime': FieldValue.serverTimestamp(),
                          });
                        },
                      ),
                  ],
                ),
              ),
            );
            continue;
          } else {
            cells.add(
              DataCell(
                Text(
                  value == 'Completed' ? "Completed" : "Cancelled",
                  style: style2(16,
                      color: value == 'Completed' ? Colors.green : Colors.red),
                ),
              ),
            );
            continue;
          }
        }

        cells.add(DataCell(
            Text(value.toString(), style: style2(16, color: Colors.black))));
      }
    } else {
      for (var i = 0; i < widget.columnNames.length; i++) {
        cells.add(const DataCell(Text('')));
      }
    }

    cells.add(
      DataCell(
        Row(
          children: [
            if (record['Payment'] == 'Unpaid' ||
                (record['Payment'] == 'Paid' && record['status'] == 'Pending'))
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
          ],
        ),
      ),
    );

    return DataRow(
      color: WidgetStateProperty.all(Colors.lightGreen.shade100),
      cells: cells,
    );
  }

  String formatDatestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateFormat formatter = DateFormat('dd MMMM yyyy');
    return formatter.format(date);
  }

  String formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(date);
  }

  String formatDateTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateFormat formatter = DateFormat('dd MMMM yyyy hh:mm a');
    return formatter.format(date);
  }
}
