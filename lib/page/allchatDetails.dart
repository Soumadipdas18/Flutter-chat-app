import 'package:flutter/material.dart';
import 'package:location/page/chatroom.dart';

class ChatDetail extends StatelessWidget {
  final String username,chatterusername, chatRoomId;

  const ChatDetail({Key? key, required this.username,required this.chatterusername, required this.chatRoomId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatRoom(chatRoomId: chatRoomId, username: username,chatterusername: chatterusername,)));
      },
      child: Column(children: <Widget>[
        Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200))
              // border: Border.symmetric(horizontal: BorderSide.none)
              ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text(username.substring(0, 1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300)),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  chatterusername,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '15:30',
                  style: TextStyle(color: Colors.grey, fontSize: 14.0),
                ),
              ],
            ),
            subtitle: Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                'Hello Modiji',
                style: TextStyle(color: Colors.grey, fontSize: 15.0),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
