import 'package:cheez_bro/utils/text.dart';
import 'package:flutter/material.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/category_managment/category_management_screen.dart';
import '../screens/admin/menu_management/menu_management_screen.dart';
import '../screens/admin/order_management/admin_order_list.dart';
import '../screens/admin/product_management/product_management_screen.dart';
import '../screens/admin/profit/profit.dart';
import '../screens/admin/sales_&_finance/sale_finance_screen.dart';
import '../screens/admin/sales_analytics/sales_analytics_screen.dart';
import '../screens/admin/staff_attendance_management/staff_attendance_management_screen.dart';
import '../screens/admin/staff_management/staff_management_screen.dart';
import '../screens/admin/staff_salary_management/staff_salary_management_screen.dart';
import '../screens/admin/users_management/user_management_screen.dart';
import '../screens/login_page.dart';

class BuildSidebar extends StatefulWidget {
  final bool isSidebarExpanded;
  const BuildSidebar({super.key, required this.isSidebarExpanded});

  @override
  BuildSidebarState createState() => BuildSidebarState();
}

class BuildSidebarState extends State<BuildSidebar> {
  void _navigateToPage(BuildContext context, Widget targetPage) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Row(
            children: [
              Expanded(child: targetPage),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isSidebarExpanded ? 280 : 80, // Sidebar expands/collapses
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                AnimatedOpacity(
                  opacity: widget.isSidebarExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text('Cheez Bro Admin',
                      style: style2(24, color: Colors.red)),
                ),
                const Spacer(),
              ],
            ),
          ),
          Divider(color: Colors.grey[700]),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSidebarTile(context, Icons.dashboard, 'Dashboard',
                      const AdminDashboard()),
                  _buildSidebarTile(context, Icons.verified_user,
                      'Users Management', const UserManagementScreen()),
                  _buildSidebarTile(context, Icons.category,
                      'Category Management', const CategoryManagementScreen()),
                  _buildSidebarTile(context, Icons.inventory,
                      'Product Management', const ProductManagementScreen()),
                  _buildSidebarTile(context, Icons.shopping_cart,
                      'Menu Management', const MenuManagementScreen()),
                  _buildSidebarTile(context, Icons.list_alt, 'Order Management',
                      const AdminOrderList()),
                  _buildSidebarTile(context, Icons.people, 'Staff Management',
                      const StaffManagementScreen()),
                  _buildSidebarTile(
                      context,
                      Icons.access_time,
                      'Staff Attendance Management',
                      const StaffAttendanceManagementScreen()),
                  _buildSidebarTile(
                      context,
                      Icons.account_balance_wallet,
                      'Staff Salary Management',
                      const StaffSalaryManagementScreen()),
                  _buildSidebarTile(context, Icons.analytics, 'Sales & Finance',
                      const SaleFinanceScreen()),
                  _buildSidebarTile(context, Icons.bar_chart, 'Sales Analytics',
                      SalesAnalyticsScreen()),
                  _buildSidebarTile(
                      context, Icons.attach_money, 'Profit', ProfitScreen()),
                  _buildSidebarTile(
                      context, Icons.logout, "Log Out", const LoginPage()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTile(
      BuildContext context, IconData icon, String title, Widget targetPage) {
    return InkWell(
      onTap: () => _navigateToPage(context, targetPage),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade800,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: AnimatedOpacity(
            opacity: widget.isSidebarExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              title,
              style: style1(14, color: Colors.white),
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
    );
  }
}
