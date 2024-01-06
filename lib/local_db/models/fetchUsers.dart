import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:while_app/local_db/models/db_helper.dart';
import 'package:while_app/resources/components/message/apis.dart';

listUsersFollowers() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(APIs.me.id)
      .collection('my_users')
      .orderBy('timeStamp', descending: true)
      .get();

  List<String> userIds = [];
  for (QueryDocumentSnapshot doc in snapshot.docs) {
    userIds.add(doc.id);
  }

  List<Map<String, dynamic>> usersInfo = [];

  for (String userId in userIds) {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      // Convert the user information to a map and add it to the list
      Map<String, dynamic> userInfo =
          userSnapshot.data() as Map<String, dynamic>;
      usersInfo.add({'userId': userId, ...userInfo});
    }
  }
  for (var data in usersInfo) {
    await DBHelper().addDataLocally(
      wholeData: jsonEncode({
        'user_id': data['userId'],
        'name': data['name'],
        'about': data['about'],
        // 'image' : img
      }),
    );
  }
  print("locally added");
  await DBHelper().printAllData();
  await DBHelper().readAllData();
  return usersInfo;
}
