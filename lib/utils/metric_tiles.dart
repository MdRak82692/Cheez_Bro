import 'package:flutter/material.dart';
import 'text.dart';

List<Widget> buildMetricTiles(Map<String, int> metrics) {
  final metricDetails = [
    {
      'title': 'Total Users',
      'value': metrics['totalUsers'],
      'color': Colors.blue,
      'icon': Icons.people
    },
    {
      'title': 'Total Menu Item',
      'value': metrics['menuItem'],
      'color': Colors.lightBlueAccent,
      'icon': Icons.fastfood
    },
    {
      'title': 'Total Staff',
      'value': metrics['totalStaff'],
      'color': Colors.brown,
      'icon': Icons.work
    },
    {
      'title': 'Today\'s Total Orders',
      'value': metrics['dailyTotalOrders'],
      'color': Colors.amber,
      'icon': Icons.shopping_cart
    },
    {
      'title': 'Today\'s Pending Orders',
      'value': metrics['dailyPendingOrders'],
      'color': Colors.green,
      'icon': Icons.hourglass_empty
    },
    {
      'title': 'Today\'s Completed Orders',
      'value': metrics['dailyCompletedOrders'],
      'color': Colors.red,
      'icon': Icons.check_circle
    },
    {
      'title': 'Today\'s Cancelled Orders',
      'value': metrics['dailyCancelledOrders'],
      'color': Colors.pink,
      'icon': Icons.cancel
    },
    {
      'title': 'Total Orders',
      'value': metrics['totalOrders'],
      'color': Colors.orange,
      'icon': Icons.assignment
    },
    {
      'title': 'Pending Orders',
      'value': metrics['pendingOrders'],
      'color': Colors.green,
      'icon': Icons.pending_actions
    },
    {
      'title': 'Completed Orders',
      'value': metrics['completedOrders'],
      'color': Colors.green,
      'icon': Icons.done
    },
    {
      'title': 'Cancelled Orders',
      'value': metrics['cancelledOrders'],
      'color': Colors.red,
      'icon': Icons.remove_shopping_cart
    },
    {
      'title': 'Total Cost',
      'value': metrics['totalCost'],
      'color': Colors.purple,
      'icon': Icons.attach_money
    },
    {
      'title': 'Total Sale',
      'value': metrics['totalSale'],
      'color': Colors.teal,
      'icon': Icons.trending_up
    },
    {
      'title': 'Total Staff Salary',
      'value': metrics['totalStaffSalary'],
      'color': const Color.fromARGB(255, 0, 150, 52),
      'icon': Icons.account_balance_wallet
    },
    {
      'title': 'Total Profit',
      'value': metrics['totalProfit'],
      'color': Colors.pink,
      'icon': Icons.monetization_on
    },
    {
      'title': 'Today\'s Cost',
      'value': metrics['dailyCost'],
      'color': Colors.cyan,
      'icon': Icons.money_off
    },
    {
      'title': 'Today\'s Sale',
      'value': metrics['dailySale'],
      'color': Colors.yellow,
      'icon': Icons.sell
    },
    {
      'title': 'Today\'s Staff Salary',
      'value': metrics['dailyStaffSalary'],
      'color': Colors.cyan,
      'icon': Icons.credit_card
    },
    {
      'title': 'Today\'s Profit',
      'value': metrics['dailyProfit'],
      'color': Colors.pink,
      'icon': Icons.trending_up
    },
    {
      'title': 'Today\'s Staff Attendance',
      'value': metrics['staffAttend'],
      'color': Colors.pink,
      'icon': Icons.event_available
    },
  ];

  return metricDetails
      .map(
        (metric) => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: (metric['color'] as Color?) ?? Colors.grey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: metric['color'] as Color? ?? Colors.grey,
                  radius: 22,
                  child: Icon(
                    metric['icon'] as IconData? ?? Icons.help_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 10),
                Text(metric['title'] as String,
                    textAlign: TextAlign.center,
                    style: style1(18, color: Colors.black)),
                const SizedBox(height: 7),
                Text('${metric['value'] ?? 0}',
                    style: style1(17, color: Colors.black)),
              ],
            ),
          ),
        ),
      )
      .toList();
}
