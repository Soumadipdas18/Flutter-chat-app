import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/page/home.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  late final User user;
  late final String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    uid = user.uid;
  }
FutureOr onGoBack(dynamic value){

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose a group")),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('usergroups')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(

                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  List rev = snapshot.data!.docs.toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 1.0, horizontal: 4.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {},
                        title: Text(rev[index]['name'].toString()),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.check_circle_outline_sharp,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            Navigator.pop(context,{'groupname':rev[index]['name'].toString()});
                          },
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
