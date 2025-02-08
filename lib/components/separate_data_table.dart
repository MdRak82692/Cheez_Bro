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
  final String fieldName;
  final dynamic staffAttendance;

  const DynamicDataTable({
    super.key,
    required this.targetWidget,
    required this.searchQuery,
    required this.collectionName,
    required this.columnNames,
    required this.columnFieldMapping,
    required this.fieldName,
    this.staffAttendance,
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
                        columns: _buildDataColumns(),
                        rows: recordsForDate
                            .map((doc) => _buildDataRow(doc))
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
          label: Text('Actions', style: style1(16, color: Colors.black)),
        ),
      );
  }

  DataRow _buildDataRow(Map<String, dynamic> record) {
    var checkInTime = record['time'];
    var checkOutTime = record['outtime'];
    String totalWorkHours = 'N/A';

    if (checkInTime is Timestamp && checkOutTime is Timestamp) {
      Duration difference =
          checkOutTime.toDate().difference(checkInTime.toDate());
      int hours = difference.inHours;
      int minutes = difference.inMinutes.remainder(60);
      totalWorkHours = "${hours}h ${minutes}m";
    }

    return DataRow(
      color: WidgetStateProperty.all(Colors.lightGreen.shade100),
      cells: widget.columnNames.map((col) {
        var fieldName = widget.columnFieldMapping[col];
        var value = record[fieldName] ?? 'N/A';

        if (col == 'Quantity') {
          var quantity = record['quantity'] ?? '0';
          var unit = record['unit'] ?? '';
          value = '$quantity $unit';
        }

        if (col == 'Total Work Hours') {
          value = totalWorkHours;
        }

        if (value is Timestamp) {
          value = formatTimestamp(value);
        }

        return DataCell(
            Text(value.toString(), style: style2(16, color: Colors.black)));
      }).toList()
        ..add(
          widget.staffAttendance == true
              ? DataCell(
                  checkOutTime == null
                      ? IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () async {
                            final now = DateTime.now();
                            await firestore
                                .collection('staffattendance')
                                .doc(record['id'])
                                .update({'outtime': now});
                          },
                        )
                      : const Icon(Icons.check, color: Colors.green),
                )
              : DataCell(
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
