import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> loadInformation({
  required String id,
  required BuildContext context,
  required Map<String, dynamic> controllers,
  required FirebaseFirestore firestore,
  required bool isLoading,
  required Function setState,
  required String collectionName,
  required List<String> fieldsToSubmit,
  bool addTimestamp = false,
}) async {
  setState(() {
    isLoading = true;
  });

  try {
    // Get the document reference from the specified collection
    DocumentSnapshot docSnapshot =
        await firestore.collection(collectionName).doc(id).get();

    if (docSnapshot.exists) {
      // Map the fields to their respective TextEditingController values
      var data = docSnapshot.data() as Map<String, dynamic>;

      // Loop through the fields to submit and set the controllers' text
      for (var field in fieldsToSubmit) {
        if (data.containsKey(field) && controllers.containsKey(field)) {
          controllers[field]?.text = data[field]?.toString() ?? '';
        }
      }
    }
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
