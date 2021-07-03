import 'dart:io';
import 'package:location/page/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:location/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchEditingController = new TextEditingController();
  bool isLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final User user;
  late final String uid;
  late QuerySnapshot searchResultSnapshot;
  bool haveUserSearched = false;
  bool errorScreen = false;
  late List users;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    uid = user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search window"),
      ),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: searchEditingController,
                            decoration: InputDecoration(
                              hintText: "Search by username",
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: initiateSearch, icon: Icon(Icons.search))
                      ],
                    ),
                  ),
                  userList()
                ],
              ),
            ),
    );
  }

  initiateSearch() async {
    if (searchEditingController.text.trim().isNotEmpty) {
      setState(() {
        isLoading = true;
      });
    }
    await FirebaseFirestore.instance
        .collection('users')
        .where("username", isEqualTo: searchEditingController.text.trim())
        .get()
        .then((querySnapshot) async {
      searchResultSnapshot = querySnapshot;
      print(
        querySnapshot.docs[0]["email"],
      );
      setState(() {
        isLoading = false;
        haveUserSearched = true;
        errorScreen = false;
      });
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
        errorScreen = true;
      });
    });
  }

  Widget userList() {
    if (errorScreen == false) {
      return haveUserSearched
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: searchResultSnapshot.docs.length,
              itemBuilder: (context, index) {
                return userTile(
                  searchResultSnapshot.docs[index]["username"],
                  searchResultSnapshot.docs[index]["email"],
                );
              })
          : Container();
    } else {
      return Container(child: Center(child: Text("No results found")));
    }
  }

  //
  Widget userTile(String userName, String userEmail) {
    return isLoading
        ? Container(
            child: Center(
            child: CircularProgressIndicator(),
          ))
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                    ),
                    Text(
                      userEmail,
                    )
                  ],
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get()
                        .then((DocumentSnapshot documentSnapshot) {
                      String chatRoomId = getChatRoomId(
                          documentSnapshot.data()['username'], userName);
                      String user1=users[0],user2=users[1];
                      Map<String, dynamic> chatRoom = {
                        "users": users,
                        "chatRoomId": chatRoomId,
                        "$user1":false,
                        "$user2":false,
                      };
                      FirebaseFirestore.instance
                          .collection("chatRoom")
                          .doc(chatRoomId)
                          .set(chatRoom)
                          .catchError((e) {
                        print(e);
                      });
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.of(context)
                          .pop({'chatroom': chatRoomId.toString()});
                    });
                  },
                  icon: Icon(Icons.message_outlined),
                )
              ],
            ),
          );
  }

  // sendMessage(String userName) {
  //   // List<String> users = [Constants.myName, userName];
  //
  //   Map<String, dynamic> chatRoom = {
  //     "users": users,
  //     "chatRoomId": chatRoomId,
  //   };
  //
  //   databaseMethods.addChatRoom(chatRoom, chatRoomId);
  //
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => Chat(
  //                 chatRoomId: chatRoomId,
  //               )));
  // }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      users = [b, a];
      return "$b\_$a";
    } else {
      users = [a, b];
      return "$a\_$b";
    }
  }
}
