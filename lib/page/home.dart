import 'dart:async';
import 'package:location/storage/sharedpref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/constants/constants.dart';
import 'package:clipboard/clipboard.dart';
import 'package:location/page/allchatDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/page/chatroom.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin,WidgetsBindingObserver {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late AppLifecycleState _applifecyclestate;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final User user;
  late dynamic groupname = null;
  String codegen = "";
  late TabController _tabController;
  late final String uid;
  bool isloading = false;
  dynamic args = null;
  final TextEditingController _codeFieldController = TextEditingController();
  late String activegroup;
  late String username;
  late List chatRoomIds = [];
  late List<ChatDetail> chattile = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Welcome to my app"),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {
                  'Create a group',
                  'Join a group',
                }.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.chat), text: "Chats"),
              Tab(icon: Icon(Icons.group), text: "Groups"),
              Tab(icon: Icon(Icons.person), text: "My Profile")
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("User"),
                accountEmail: Text(user.email),
                currentAccountPicture: Image.asset('assets/images/picon.png'),
                otherAccountsPictures: [
                  IconButton(
                      onPressed: () async {
                        auth.signOut();
                        Navigator.of(context).pop();
                        setState(() {
                          isloading = true;
                        });
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        await preferences.clear();
                        setState(() {
                          isloading = false;
                        });
                        Navigator.of(context).pushReplacementNamed(SIGN_IN);
                      },
                      icon: Icon(Icons.logout))
                ],
              ),
              Padding(
                  padding: EdgeInsets.all(2),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          child: Text("Choose a group"),
                          onPressed: () async {
                            setState(() async {
                              groupname =
                                  await Navigator.pushNamed(context, GROUP);
                              setState(() {});
                            });
                          },
                        ),
                      )
                      // StreamBuilder(builder: builder)
                    ],
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: groupname == null
                    ? Container()
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('groups')
                            .doc(groupname['groupname'])
                            .collection(groupname['groupname'])
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                      title: Text(
                                          rev[index]['username'].toString()),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          //delete from 2 places
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.message),
          onPressed: () async {
            dynamic chatRoomId = await Navigator.of(context).pushNamed(SEARCH);
            if (chatRoomId != null) {
              setState(() {
                isloading = true;
              });
              if (!chatRoomIds.contains(chatRoomId['chatroom'])) {
                chatRoomIds.add(chatRoomId['chatroom']);
              }
              sharedpref pref = new sharedpref();
              bool check = await pref.saveListOfChats(chatRoomIds);
              print(chatRoomIds);
              setState(() {
                chattile = [];
              });
              await getshared();
              setState(() {
                isloading = false;
              });
            }
          },
        ),
        body: TabBarView(controller: _tabController, children: [
          ChatPageView(context),
          GroupPageView(context),
          ProfileView(context)
        ]));
  }

  Widget ChatPageView(BuildContext context) {
    return isloading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
          )
        : Container(
            child: ListView.builder(
                itemCount: chattile.length,
                itemBuilder: (context, index) {
                  return chattile[index];
                }));
  }

  Widget GroupPageView(BuildContext context) {
    return Container();
  }

  Widget ProfileView(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    user = auth.currentUser;
    uid = user.uid;
    _tabController = TabController(vsync: this, length: 3);
    getshared();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _applifecyclestate=state;
    print(_applifecyclestate);

  }
  @override
  void dispose() {
    print("FF");

    // FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(uid)
    //     .get()
    //     .then((DocumentSnapshot documentSnapshot) {
    //   username = documentSnapshot.data()['username'];
    // });
    // setEditchange(false,username);
  _tabController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();

  }
  Future<void> setEditchange(bool falsetrue,String un) async {
    FirebaseFirestore.instance
        .collection('chatRoom')
        .snapshots()
        .listen((snapshot) {
      snapshot.docs.fold(0, (tot, doc) async {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentReference documentReference = await FirebaseFirestore.instance
              .collection('chatRoom')
              .doc(doc.data()['chatRoomID']);
          DocumentSnapshot snapshot = await transaction.get(documentReference);
          if (snapshot.exists) {
            transaction.update(documentReference,
                {'$un': 'last seen at ${DateTime
                    .now()
                    .millisecondsSinceEpoch}'
                });
          }
        });
      });
    });}
  getshared() async {
    setState(() {
      isloading = true;
    });
    sharedpref pref = new sharedpref();
    try {
      chatRoomIds = (await pref.getListOfChats())!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        username = documentSnapshot.data()['username'];
        print(username);
      });
      //extract sender username
      if (chatRoomIds.length != null || chatRoomIds.length != 0) {
        for (int i = 0; i < chatRoomIds.length; i++) {
          String rem = chatRoomIds[i].replaceAll(username, '');
          if (rem[0] == '_') {
            rem = rem.substring(1, rem.length);
          } else {
            rem = rem.substring(0, rem.length - 1);
          }
          ChatDetail detail =
              new ChatDetail(username: username,chatterusername: rem, chatRoomId: chatRoomIds[i]);
          chattile.insert(0, detail);
        }
      }
      setState(() {
        isloading = false;
      });
    } catch (e) {
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> handleClick(String value) async {
    switch (value) {
      //Create grp
      case 'Create a group':
        setState(() {
          isloading = true;
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            setState(() {
              int index = documentSnapshot.data()['groups'];
              setState(() {
                isloading = false;
              });

              return creategroupalertdialoguewidget(context, index);
            });

            print('Document data: ${documentSnapshot.data()}');
          } else {
            print('Document does not exist on the database');
          }
        });
        break;
      //Join grp
      case 'Join a group':
        joinagroupalertwindow(context);
        break;
    }
  }

  creategroupalertdialoguewidget(BuildContext context, index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add members using the code"),
            content: Text(uid.substring(0, 10) + index.toString()),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    FlutterClipboard.copy(
                            uid.substring(0, 10) + index.toString())
                        .then((value) => ScaffoldMessenger.of(context)
                            .showSnackBar(
                                SnackBar(content: Text('Code Copied'))));
                  },
                  child: Text("Copy Code")),
              ElevatedButton(
                  onPressed: () async {
                    await groupcreate(
                        uid.substring(0, 10) + index.toString(), index);
                    FlutterClipboard.copy(
                        uid.substring(0, 10) + index.toString());
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Code copied to clipboard and Group Created.')));
                  },
                  child: Text("Create Group")),
              ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text("Done")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      isloading = false;
                    });
                  },
                  child: Text("Cancel")),
            ],
          );
        });
  }

  Future<void> groupcreate(String code, int index) async {
    //Map stores user auth details
    late Map<String, dynamic> mapuser;
    //get auth details
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        mapuser = documentSnapshot.data();
        //update index
        setState(() {
          index += 1;
        });
        //change auth details in users
        DocumentReference documentReference =
            FirebaseFirestore.instance.collection('users').doc(uid);
        FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(documentReference);
          if (snapshot.exists) {
            transaction.update(documentReference, {'groups': index});
          }
        });
        //store auth details in groups
        CollectionReference users =
            FirebaseFirestore.instance.collection("groups");
        users.doc(code).collection(code).doc(code).set(mapuser).then((value) {
          Map<String, dynamic> mp = {'name': code};
          CollectionReference users =
              FirebaseFirestore.instance.collection('users');
          users.doc(uid).collection('usergroups').doc(code).set(mp);
        }).catchError((error) => print("Failed to adduser: $error"));

        print('Document data: ${documentSnapshot.data()}');
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  Future<dynamic> joinagroupalertwindow(BuildContext context) async {
    // alter the app state to show a dialog

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Join a group'),
            content: TextField(
                controller: _codeFieldController,
                decoration: InputDecoration(
                  hintText: 'Enter a code',
                )),
            actions: <Widget>[
              // add button
              ElevatedButton(
                  child: Text('ADD'),
                  onPressed: () {
                    //chcek if user entered group is available or

                    setState(() {
                      isloading = true;
                    });
                    FirebaseFirestore.instance
                        .collection('groups')
                        .doc(_codeFieldController.text)
                        .collection(_codeFieldController.text)
                        .doc(_codeFieldController.text)
                        .get()
                        .then((DocumentSnapshot documentSnapshot) async {
                      if (!documentSnapshot.exists) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Code is invalid. Try again')));
                        _codeFieldController.clear();
                        print("Error");
                        setState(() {
                          isloading = false;
                          Navigator.of(context).pop();
                        });
                      } else {
                        print("Group found");
                        String groupcode = _codeFieldController.text;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Group joined')));
                        Navigator.of(context).pop();
                        //get the data from user collection
                        late Map<String, dynamic> mapuser;
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .get()
                            .then((DocumentSnapshot documentSnapshot) {
                          if (documentSnapshot.exists) {
                            //adding in mapuser
                            mapuser = documentSnapshot.data();
                            CollectionReference users =
                                FirebaseFirestore.instance.collection('groups');
                            users
                                .doc(groupcode)
                                .collection(groupcode)
                                .doc(uid)
                                .set(mapuser)
                                .then((value) {
                              //adding groupdata in users
                              Map<String, dynamic> mp = {'name': groupcode};
                              CollectionReference users = FirebaseFirestore
                                  .instance
                                  .collection('users');
                              users
                                  .doc(uid)
                                  .collection('usergroups')
                                  .doc(groupcode)
                                  .set(mp);
                              //snackbar group joined
                            }).catchError((error) =>
                                    print("Failed to adduser: $error"));
                          }
                        });
                        setState(() {
                          isloading = false;
                        });
                      }
                    });
                  }),
              // Cancel button
              ElevatedButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _codeFieldController.clear();
                },
              )
            ],
          );
        });
  }
}
