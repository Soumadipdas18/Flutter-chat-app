import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'SingleChatMessageTile.dart';

class ChatRoom extends StatefulWidget {
  final String chatRoomId, username, chatterusername;

  const ChatRoom(
      {Key? key,
      required this.chatRoomId,
      required this.username,
      required this.chatterusername})
      : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with WidgetsBindingObserver {
  late AppLifecycleState _applifecyclestate;
  bool iseditchange = false;
  bool isLoading = false;
  bool isEdit = false;
  late Stream<QuerySnapshot> chats;
  late final User user;
  late final String uid;
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _textController = new TextEditingController();
  final chatFocusNode = FocusNode();
  Map<String, dynamic> chatMessageMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Chat with ${widget.chatterusername}"),
          centerTitle: true,
          bottom: PreferredSize(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chatRoom')
                      .where('chatRoomId', isEqualTo: widget.chatRoomId)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    return snapshot.hasData
                        ? Container(
                            child: Text(snapshot.data!.docs[0][widget.chatterusername]
                                .toString()))
                        : Container();
                  }),
              preferredSize: Size.fromHeight(0.0))),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/backgroundchat.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chatRoom')
                        .doc(widget.chatRoomId)
                        .collection('chats')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      return snapshot.hasData
                          ? Scrollbar(
                              child: ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onLongPress: () {
                                        msgoperationpopup(
                                            context,
                                            index,
                                            snapshot.data!.docs[index]
                                                ["message"],
                                            snapshot);
                                        setEditchange(false);
                                      },
                                      onTap: (){},
                                      child: MessageTile(
                                        message: snapshot.data!.docs[index]
                                            ["message"],
                                        sendByMe: widget.username ==
                                            snapshot.data!.docs[index]
                                                ["sendBy"],
                                        milisec: snapshot.data!.docs[index]
                                            ["time"],
                                      ),
                                    );
                                  }),
                            )
                          : Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
          new Divider(
            height: 1.0,
          ),
          new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _textComposerWidget(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    user = auth.currentUser;
    uid = user.uid;
  }
  @override
  void didChangeAppLifeCycleState(AppLifecycleState state){
    print(_applifecyclestate);
    _applifecyclestate=state;


      if(_applifecyclestate==AppLifecycleState.paused){
        setEditchange(false);
      }

    print(_applifecyclestate);
    setState(() {});
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    chatFocusNode.dispose();
    setEditchange(false);
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Future<void> setChatData(String text, int time) async {
    if (chatMessageMap != {}) {
      await FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(chatMessageMap);
      chatMessageMap = {};
    }
  }

  Widget _textComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: new TextField(
                  enableSuggestions: true,
                  focusNode: chatFocusNode,
                  onChanged: (text) {
                    if (text != '') {
                      setState(() {
                        isEdit = true;
                      });
                      setEditchange(true);
                    } else {
                      setState(() {
                        isEdit = false;
                      });
                      setEditchange(false);
                    }
                  },
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                  controller: _textController,
                ),
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Container(
                    child: isEdit
                        ? null
                        : IconButton(
                            icon: new Icon(Icons.add_a_photo_outlined),
                            onPressed: () => {},
                          ),
                  ),
                  Container(
                    child: IconButton(
                      icon: new Icon(Icons.send),
                      onPressed: () =>
                          _handleSubmitted(_textController.text.trim()),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text != '') {
      setState(() {
        isEdit = false;
      });
      setEditchange(false);
      _textController.clear();
      chatMessageMap = {
        "sendBy": widget.username,
        "message": text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      setChatData(text, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> setEditchange(bool falsetrue) async {
    String username = widget.username;
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(widget.chatRoomId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      if (snapshot.exists) {
        if(falsetrue==true) {
          transaction.update(documentReference,
              {'$username': '${widget.username} is typing'});
        }
        else{
          transaction.update(documentReference,
              {'$username': 'online'});
        }
      }
    });
  }

  msgoperationpopup(BuildContext context, int index, String msg,
      AsyncSnapshot<QuerySnapshot> snapshot) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("'$msg'"),
            actions: [
              TextButton(
                  onPressed: () {
                    FlutterClipboard.copy(msg).then((value) =>
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Message Copied'))));
                  },
                  child: Text("Copy message")),
              TextButton(onPressed: () {}, child: Text("Delete for me")),
              TextButton(
                  onPressed: () async {
                    await deleteeveryone(index, snapshot);
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  },
                  child: Text("Delete for everyone")),
              TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel")),
            ],
          );
        });
  }

  Future<void> deleteeveryone(
      int index, AsyncSnapshot<QuerySnapshot> snapshot) async {
    await FirebaseFirestore.instance
        .runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(snapshot.data!.docs[index].reference);
    });
  }
}
