import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final int milisec;

  MessageTile(
      {required this.message, required this.sendByMe, required this.milisec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 2, bottom: 2, left: sendByMe ? 0 : 12, right: sendByMe ? 12 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10))
                : BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
            gradient: LinearGradient(
              colors: sendByMe
                  ? [const Color(0xff00BEFF), const Color(0xff5ec0e5)]
                  : [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
            )),
        child: Column(
            crossAxisAlignment:
                sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(message,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w400)),
              SizedBox(
                height: 7.0,
              ),
              Text(timeConvert(milisec),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: Color(0xFF7B7575),
                      fontSize: 10,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300))
            ]),
      ),
    );
  }

  String timeConvert(int timeInMillis) {
    var time = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
    var formattedtime = DateFormat('hh:mm a').format(time);
    return formattedtime;
  }
}
