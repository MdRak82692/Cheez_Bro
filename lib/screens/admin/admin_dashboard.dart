import 'package:flutter/material.dart';
import '../../utils/metric_tiles.dart';
import '../../utils/header.dart';
import '../../utils/slider_bar.dart';
import '../../utils/dashboard_metrics.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              const BuildSidebar(isSidebarExpanded: true),
              Expanded(
                child: Column(
                  children: [
                    buildHeader(context),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: FutureBuilder<Map<String, int>>(
                          future: fetchDashboardMetrics(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blueAccent),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                  'Error loading metrics.',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }

                            final metrics = snapshot.data ?? {};
                            return AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 500),
                              child: GridView(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width > 1200
                                          ? 4
                                          : 1,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                                children: buildMetricTiles(metrics),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
