import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../components/title_section.dart';
import '../../../utils/slider_bar.dart';
import '../../../utils/text.dart';

class ProfitScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ProfitScreen({super.key});

  Future<List<Map<String, dynamic>>> getChartData(String groupBy) async {
    List<Map<String, dynamic>> chartData = [];
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;

    var orderSnapshot = await firestore.collection("orders").get();
    var productSnapshot = await firestore.collection("products").get();
    var salarySnapshot = await firestore.collection("staffsalary").get();

    Map<String, double> profitMap = {};

    void processData(QuerySnapshot snapshot, String timeField,
        String valueField, bool isNegative) {
      for (var doc in snapshot.docs) {
        DateTime time = doc[timeField].toDate();
        double value = double.tryParse(doc[valueField].toString()) ?? 0.0;
        if (isNegative) value = -value;

        String groupKey = "";
        bool isValid = false;

        if (groupBy == 'day' && time.month == currentMonth) {
          groupKey = time.day.toString();
          isValid = true;
        } else if (groupBy == 'month' && time.year == currentYear) {
          groupKey = getMonthName(time.month);
          isValid = true;
        } else if (groupBy == 'year') {
          groupKey = time.year.toString();
          isValid = true;
        }

        if (isValid) {
          profitMap[groupKey] = (profitMap[groupKey] ?? 0.0) + value;
        }
      }
    }

    processData(orderSnapshot, "time", "sale", false);
    processData(productSnapshot, "time", "cost", true);
    processData(salarySnapshot, "time", "salary", true);

    profitMap.forEach((key, value) {
      chartData.add({'date': key, 'value': value});
    });

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
                        title: 'Profit Analytics',
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
                        buildSectionTitle("Profit", context),
                        buildBarChart(context, "Profit vs Day", "day"),
                        buildBarChart(context, "Profit vs Month", "month"),
                        buildBarChart(context, "Profit vs Year", "year"),
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

  Widget buildBarChart(BuildContext context, String title, String groupBy) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getChartData(groupBy),
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

          double minValue = barChartData.fold<double>(0, (prev, element) {
            double currentValue = element.barRods.first.toY;
            return currentValue < prev ? currentValue : prev;
          });

          double xAxisMax = (maxValue / 2000).ceil() * 2000;
          double xAxisMin = (minValue / 2000).floor() * 2000;

          xAxisMin = xAxisMin - 2000;
          xAxisMax = xAxisMax + 2000;

          // Create the Y-axis labels using a loop
          List<String> yAxisLabels = [];
          for (double i = xAxisMin; i <= xAxisMax; i += 2000) {
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
                            reservedSize: 70,
                            getTitlesWidget: (value, meta) {
                              int index = ((value - xAxisMin) / 2000).toInt();
                              if (index >= 0 && index < yAxisLabels.length) {
                                return Text(
                                  yAxisLabels[index],
                                  style: style2(14, color: Colors.black),
                                );
                              } else {
                                return Container(); // Hide out-of-bound labels
                              }
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              if (groupBy == 'month') {
                                return Text(
                                  getMonthName(value.toInt()),
                                  style: style2(14, color: Colors.blue),
                                );
                              } else if (groupBy == 'year') {
                                return Text(
                                  value.toInt().toString(),
                                  style: style2(14, color: Colors.green),
                                );
                              } else {
                                return Text(
                                  value.toInt().toString(),
                                  style: style2(14, color: Colors.red),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      barGroups: barChartData,
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        checkToShowHorizontalLine: (value) => value % 2000 == 0,
                      ),
                      maxY: xAxisMax,
                      minY: xAxisMin,
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
    if (value >= 0) {
      return ((value / 2000).ceil()) * 2000.toDouble();
    } else {
      return ((value.abs() / 2000).ceil()) * -2000.toDouble();
    }
  }

  List<BarChartGroupData> generateBarChartData(
      List<Map<String, dynamic>> data, String groupBy) {
    List<BarChartGroupData> barChartData = [];
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    if (groupBy == 'day') {
      int daysInMonth = getDaysInMonth(currentMonth, currentYear);
      for (int i = 1; i <= daysInMonth; i++) {
        double value = data
            .firstWhere(
              (element) => element['date'] == i.toString(),
              orElse: () => {'value': 0},
            )['value']
            .toDouble();

        barChartData.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                color: value >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        );
      }
    } else if (groupBy == 'month') {
      for (int i = 1; i <= 12; i++) {
        double value = data
            .firstWhere(
              (element) => element['date'] == getMonthName(i),
              orElse: () => {'value': 0},
            )['value']
            .toDouble();

        barChartData.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                color: value >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        );
      }
    } else if (groupBy == 'year') {
      for (int i = currentYear - 1; i <= currentYear; i++) {
        double value = data
            .firstWhere(
              (element) => element['date'] == i.toString(),
              orElse: () => {'value': 0},
            )['value']
            .toDouble();

        barChartData.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                color: value >= 0 ? Colors.green : Colors.red,
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
