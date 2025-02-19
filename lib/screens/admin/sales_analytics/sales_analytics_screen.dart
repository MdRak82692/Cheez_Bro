import 'package:cheez_bro/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';

class SalesAnalyticsScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  SalesAnalyticsScreen({super.key});

  Future<List<Map<String, dynamic>>> getChartData(String collection,
      String timeField, String valueField, String groupBy) async {
    QuerySnapshot snapshot = await firestore.collection(collection).get();
    List<Map<String, dynamic>> chartData = [];
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;

    for (var doc in snapshot.docs) {
      DateTime time = doc[timeField].toDate();
      int value = doc[valueField];

      String groupKey = "";
      bool isValidData = false;

      if (groupBy == 'day') {
        if (time.month == currentMonth) {
          groupKey = time.day.toString();
          isValidData = true;
        }
      } else if (groupBy == 'month') {
        if (time.year == currentYear) {
          groupKey = getMonthName(time.month);
          isValidData = true;
        }
      } else if (groupBy == 'year') {
        groupKey = time.year.toString();
        isValidData = true;
      } else {
        throw Exception("Invalid grouping unit");
      }

      if (isValidData) {
        bool found = false;
        for (var entry in chartData) {
          if (entry['date'] == groupKey) {
            entry['value'] += value;
            found = true;
            break;
          }
        }

        if (!found) {
          chartData.add({'date': groupKey, 'value': value});
        }
      }
    }
    return chartData;
  }

  String getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  int getDaysInMonth(int month, int year) {
    if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
      } else {
        return 28;
      }
    } else if ([1, 3, 5, 7, 8, 10, 12].contains(month)) {
      return 31;
    } else {
      return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BuildSidebar(isSidebarExpanded: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TitleSection(
                        title: 'Sale Analytics',
                        addIcon: false,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSectionTitle("Product Cost", context),
                        buildBarChart(
                          context,
                          "Cost vs Day",
                          "products",
                          "time",
                          "cost",
                          "day",
                        ),
                        buildBarChart(
                          context,
                          "Cost vs Month",
                          "products",
                          "time",
                          "cost",
                          "month",
                        ),
                        buildBarChart(
                          context,
                          "Cost vs Year",
                          "products",
                          "time",
                          "cost",
                          "year",
                        ),
                        buildSectionTitle("Item Sale", context),
                        buildBarChart(
                          context,
                          "Sale vs Day",
                          "orders",
                          "time",
                          "sale",
                          "day",
                        ),
                        buildBarChart(
                          context,
                          "Sale vs Month",
                          "orders",
                          "time",
                          "sale",
                          "month",
                        ),
                        buildBarChart(
                          context,
                          "Sale vs Year",
                          "orders",
                          "time",
                          "sale",
                          "year",
                        ),
                        buildSectionTitle("Staff Salary", context),
                        buildBarChart(
                          context,
                          "Salary vs Day",
                          "staffsalary",
                          "time",
                          "salary",
                          "day",
                        ),
                        buildBarChart(
                          context,
                          "Salary vs Month",
                          "staffsalary",
                          "time",
                          "salary",
                          "month",
                        ),
                        buildBarChart(
                          context,
                          "Salary vs Year",
                          "staffsalary",
                          "time",
                          "salary",
                          "year",
                        ),
                        const SizedBox(height: 30),
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

  Widget buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Text(title, style: style2(24, color: Colors.black)),
    );
  }

  Widget buildBarChart(BuildContext context, String title, String collection,
      String timeField, String valueField, String groupBy) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getChartData(collection, timeField, valueField, groupBy),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          List<BarChartGroupData> barChartData =
              generateBarChartData(snapshot.data!, groupBy);

          double maxValue = barChartData.fold<double>(0, (prev, element) {
            double currentValue = element.barRods.first.toY;
            return currentValue > prev ? currentValue : prev;
          });

          double xAxisMax = (maxValue / 2000).ceil() * 2000;

          List<String> yAxisLabels = [];
          for (double i = 0; i <= xAxisMax; i += 2000) {
            yAxisLabels.add(i.toInt().toString());
          }
          String subtitle = "";
          if (groupBy == 'day') {
            subtitle = "Current Month: ${getCurrentMonthName()}";
          } else if (groupBy == 'month') {
            subtitle = "Year: ${DateTime.now().year}";
          }

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: style2(18, color: Colors.black)),
                const SizedBox(height: 16),
                Text(title, style: style2(20, color: Colors.black)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              int index = ((value - 0) / 2000).toInt();
                              if (index >= 0 && index < yAxisLabels.length) {
                                return Text(
                                  yAxisLabels[index],
                                  style: style2(14, color: Colors.black),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (groupBy == 'month') {
                                return Text(getMonthName(value.toInt()),
                                    style: style2(14, color: Colors.blue));
                              } else if (groupBy == 'year') {
                                return Text(value.toInt().toString(),
                                    style: style2(14, color: Colors.green));
                              } else {
                                return Text(value.toInt().toString(),
                                    style: style2(14, color: Colors.red));
                              }
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      barGroups: barChartData,
                      gridData: FlGridData(
                        show: true,
                        checkToShowHorizontalLine: (value) => value % 2000 == 0,
                      ),
                      maxY: xAxisMax,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  double getNextRoundedValue(double value) {
    int roundedValue = ((value / 2000).ceil()) * 2000;
    return roundedValue.toDouble();
  }

  List<BarChartGroupData> generateBarChartData(
      List<Map<String, dynamic>> data, String groupBy) {
    List<BarChartGroupData> barChartData = [];
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    if (groupBy == 'day') {
      int daysInMonth = getDaysInMonth(currentMonth, currentYear);
      for (int i = 1; i <= daysInMonth; i++) {
        barChartData.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data
                    .firstWhere(
                      (element) => element['date'] == i.toString(),
                      orElse: () => {'value': 0},
                    )['value']
                    .toDouble(),
                color: Colors.blue,
              ),
            ],
          ),
        );
      }
    } else if (groupBy == 'month') {
      for (int i = 1; i <= 12; i++) {
        barChartData.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data
                    .firstWhere(
                      (element) => getMonthName(i) == element['date'],
                      orElse: () => {'value': 0},
                    )['value']
                    .toDouble(),
                color: Colors.green,
              ),
            ],
          ),
        );
      }
    } else if (groupBy == 'year') {
      for (var entry in data) {
        int year = int.parse(entry['date']);
        barChartData.add(
          BarChartGroupData(
            x: year,
            barRods: [
              BarChartRodData(
                toY: entry['value'].toDouble(),
                color: Colors.red,
              ),
            ],
          ),
        );
      }
    }
    return barChartData;
  }

  String getCurrentMonthName() {
    int currentMonth = DateTime.now().month;
    return getMonthName(currentMonth);
  }
}
