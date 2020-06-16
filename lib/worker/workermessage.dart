import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var messagesSnapshot = Firestore.instance.collection("messages").orderBy("timestamp", descending: true).snapshots();
    var usersSnapshot = Firestore.instance.collection("users").snapshots();
    var streamBuilder = StreamBuilder<QuerySnapshot>(
      stream: messagesSnapshot,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> messagesSnapshot) {
        return StreamBuilder(
          stream: usersSnapshot,
          builder: (context, usersSnapshot) {
            if (messagesSnapshot.hasError || usersSnapshot.hasError || !usersSnapshot.hasData)
              return new Text('Error: ${messagesSnapshot.error}, ${usersSnapshot.error}');
            switch (messagesSnapshot.connectionState) {
              case ConnectionState.waiting: return new Text("Loading...");
              default:
                return new ListView(
                  children: messagesSnapshot.data.documents.map((DocumentSnapshot doc) {
                    var user = "";
                    if (doc['uid'] != null && usersSnapshot.data != null) {
                      user = doc['uid'];
                      print('Looking for user $user');
                      user = usersSnapshot.data.documents.firstWhere((userDoc) => userDoc.documentID == user).data["name"];
                    }
                    return new ListTile(
                      title: new Text(doc['message']),
                      subtitle: new Text(DateTime.fromMillisecondsSinceEpoch(doc['timestamp']).toString()
                                          +"\n"+user),
                    );
                  }).toList()
                );
            }
        });
      }
    );
    return streamBuilder;
  }
}