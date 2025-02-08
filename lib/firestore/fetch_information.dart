import 'package:cloud_firestore/cloud_firestore.dart';

class FetchInformation {
  final FirebaseFirestore firestore;
  Function(void Function()) setState;

  FetchInformation({required this.firestore, required this.setState});

  String? selectedCategory;
  String? selectedSize;
  String? selectedStaff;

  List<String> categories = [];
  List<String> sizes = [];
  List<String> alreadyMarked = [];
  List<Map<String, dynamic>> staffList = [];
  List<String> excludedStaffNames = [];
  List<Map<String, String>> excludedStaffNamesAndPositions = [];

  Future<void> fetchCategories() async {
    QuerySnapshot querySnapshot = await firestore.collection('category').get();
    setState(() {
      categories = querySnapshot.docs
          .map((doc) => doc['categoryName'] as String)
          .toList();
    });
  }

  void updateSizes(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'Pizza') {
        sizes = ['6-inch', '8-inch', '12-inch'];
      } else if (category == 'Meat Box') {
        sizes = ['Small', 'Medium', 'Large'];
      } else {
        sizes = [];
      }
      selectedSize = null;
    });
  }

  Future<void> fetchStaffNames() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      final attendanceSnapshot = await firestore
          .collection('staffattendance')
          .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      alreadyMarked = attendanceSnapshot.docs
          .map((doc) => doc['staff_name'] as String)
          .toList();

      final staffSnapshot = await firestore.collection('staff').get();

      setState(() {
        staffList = staffSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': "${doc['first_name']} ${doc['last_name']}",
                  'position': doc['position'],
                })
            .where((staff) => !alreadyMarked.contains(staff['name']))
            .toList();
      });
    } finally {}
  }

  Future<void> fetchStaffData() async {
    try {
      final salarySnapshot =
          await firestore.collection('staffsalaryinformation').get();

      excludedStaffNamesAndPositions = salarySnapshot.docs
          .map((doc) => {
                'name': doc['staff_name'] as String,
                'position': doc['position'] as String,
              })
          .toList();

      final staffSnapshot = await firestore.collection('staff').get();

      setState(() {
        staffList = staffSnapshot.docs
            .map((doc) => {
                  'name': "${doc['first_name']} ${doc['last_name']}",
                  'position': doc['position'],
                })
            .where((staff) {
          return !excludedStaffNamesAndPositions.any(
            (excludedStaff) =>
                excludedStaff['name'] == staff['name'] &&
                excludedStaff['position'] == staff['position'],
          );
        }).toList();
      });
    } finally {}
  }
}
