// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, int>> fetchDashboardMetrics() async {
  final firestore = FirebaseFirestore.instance;
  final metrics = {
    'totalUsers': 0,
    'dailyTotalOrders': 0,
    'dailyCompletedOrders': 0,
    'dailyPendingOrders': 0,
    'dailyCancelledOrders': 0,
    'totalOrders': 0,
    'pendingOrders': 0,
    'completedOrders': 0,
    'cancelledOrders': 0,
    'totalCost': 0,
    'totalSale': 0,
    'dailyCost': 0,
    'dailySale': 0,
    'dailyProfit': 0,
    'dailyStaffSalary': 0,
    'totalStaffSalary': 0,
    'totalProfit': 0,
    'totalStaff': 0,
    'staffAttend': 0,
    'menuItem': 0,
  };

  try {
    final userSnapshot = await firestore.collection('users').get();
    final orderSnapshot = await firestore.collection('orders').get();
    final productSnapshot = await firestore.collection('products').get();
    final staffSnapshot = await firestore.collection('staff').get();
    final staffSalarySnapshot = await firestore.collection('staffsalary').get();
    final menuSnapShot = await firestore.collection('menu').get();

    metrics['totalUsers'] = userSnapshot.size;
    metrics['menuItem'] = menuSnapShot.size;

    metrics['totalOrders'] = orderSnapshot.size;
    metrics['pendingOrders'] =
        orderSnapshot.docs.where((doc) => doc['status'] == 'Pending').length;
    metrics['completedOrders'] =
        orderSnapshot.docs.where((doc) => doc['status'] == 'Completed').length;
    metrics['cancelledOrders'] =
        orderSnapshot.docs.where((doc) => doc['status'] == 'Cancelled').length;

    metrics['totalCost'] = productSnapshot.docs
        // ignore: avoid_types_as_parameter_names
        .fold<int>(0, (sum, doc) => sum + (doc['cost'] as int? ?? 0));

    metrics['totalSale'] = orderSnapshot.docs.fold<int>(
      0,
      // ignore: avoid_types_as_parameter_names
      (sum, doc) => (doc['status'] == 'Completed')
          ? sum + (doc['sale'] as int? ?? 0)
          : sum,
    );

    metrics['totalStaffSalary'] = staffSalarySnapshot.docs
        // ignore: avoid_types_as_parameter_names
        .fold<int>(0, (sum, doc) => sum + (doc['salary'] as int? ?? 0));

    // Calculate total profit
    metrics['totalProfit'] = (metrics['totalSale'] ?? 0) -
        (metrics['totalCost'] ?? 0) -
        (metrics['totalStaffSalary'] ?? 0);

    // Define start and end timestamps for today
    final todayStart = Timestamp.fromDate(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ));
    final todayEnd = Timestamp.fromDate(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      23,
      59,
      59,
    ));

    // Fetch today's cost
    final dailyCostSnapshot = await firestore
        .collection('products')
        .where('time', isGreaterThanOrEqualTo: todayStart)
        .where('time', isLessThanOrEqualTo: todayEnd)
        .get();
    metrics['dailyCost'] = dailyCostSnapshot.docs
        // ignore: avoid_types_as_parameter_names
        .fold<int>(0, (sum, doc) => sum + (doc['cost'] as int? ?? 0));

    final dailyMetricsSalesQuery = await firestore
        .collection('orders')
        .where('status', isEqualTo: 'Completed')
        .get();

    // Filter documents in code
    final dailySalesSnapshot = dailyMetricsSalesQuery.docs.where((doc) {
      final timestamp = doc['time'] as Timestamp;
      final dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
      return dateTime.isAfter(todayStart.toDate()) &&
          dateTime.isBefore(todayEnd.toDate());
    }).toList();

    // Calculate daily sale sum
    metrics['dailySale'] = dailySalesSnapshot.fold<int>(
      0,
      // ignore: avoid_types_as_parameter_names
      (sum, doc) => sum + (doc['sale'] as int? ?? 0),
    );

    final dailyStaffSalarySnapshot = await firestore
        .collection('staffsalary')
        .where('time', isGreaterThanOrEqualTo: todayStart)
        .where('time', isLessThanOrEqualTo: todayEnd)
        .get();
    metrics['dailyStaffSalary'] = dailyStaffSalarySnapshot.docs
        // ignore: avoid_types_as_parameter_names
        .fold<int>(0, (sum, doc) => sum + (doc['salary'] as int? ?? 0));

    // Calculate today's profit
    metrics['dailyProfit'] = (metrics['dailySale'] ?? 0) -
        (metrics['dailyCost'] ?? 0) -
        (metrics['dailyStaffSalary'] ?? 0);

    metrics['totalStaff'] = staffSnapshot.size;
    final staffAttendSnapshot = await firestore
        .collection('staffattendance')
        .where('time', isGreaterThanOrEqualTo: todayStart)
        .where('time', isLessThanOrEqualTo: todayEnd)
        .get();
    metrics['staffAttend'] = staffAttendSnapshot.size;

    final dailyTotalOrders = await firestore
        .collection('orders')
        .where('time', isGreaterThanOrEqualTo: todayStart)
        .where('time', isLessThanOrEqualTo: todayEnd)
        .get();

    metrics['dailyTotalOrders'] = dailyTotalOrders.size;
    metrics['dailyPendingOrders'] =
        dailyTotalOrders.docs.where((doc) => doc['status'] == 'Pending').length;
    metrics['dailyCompletedOrders'] = dailyTotalOrders.docs
        .where((doc) => doc['status'] == 'Completed')
        .length;
    metrics['dailyCancelledOrders'] = dailyTotalOrders.docs
        .where((doc) => doc['status'] == 'Cancelled')
        .length;
  } catch (e) {
    // ignore: avoid_print
    print('Error fetching dashboard metrics: $e');
  }

  return metrics;
}
