import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:taar3/Helper/Constants.dart';
import 'package:taar3/Services/DatabaseMethods.dart';
import 'package:taar3/Widgets/Widgets.dart';

class Chat extends StatefulWidget {
  String chatRoomId;
  Chat({@required this.chatRoomId});
  @override
  _ChatState createState() => _ChatState(chatRoomId);
}

class _ChatState extends State<Chat> {
  String chatRoomId;
  _ChatState(this.chatRoomId);
  // String chatRoomId = "hayy_keva";
  Stream chats;
  String currentUserName;
  ScrollController _scrollController = new ScrollController();
  TextEditingController messageEditingController = new TextEditingController();
  void initState() {
    getUserInfo();
    DatabaseMethods().getChats(chatRoomId).then((val) {
      chats = val;
      setState(() {});
    });
    super.initState();
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        // chats.listen((event) {
        //   print(event);
        // });

        return snapshot.hasData
            ? ListView.builder(
                controller: _scrollController,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.docs[index]["message"],
                    sendByMe:
                        currentUserName == snapshot.data.docs[index]["sendBy"],
                  );
                })
            : Container();
      },
    );
  }

  sendMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      print(currentUserName);
      Map<String, dynamic> chatMessageMap = {
        "sendBy": currentUserName ?? "username",
        "message": messageEditingController.text ?? "message",
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      await DatabaseMethods().addMessage(chatRoomId, chatMessageMap);

      setState(() {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);

        messageEditingController.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Column(
        children: [
          Expanded(
            child: chatMessages(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              color: Color(0x54FFFFFF),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: messageEditingController,
                    style: simpleTextStyle(),
                    decoration: InputDecoration(
                        hintText: "Message ...",
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        border: InputBorder.none),
                  )),
                  SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0x36FFFFFF),
                                  const Color(0x0FFFFFFF)
                                ],
                                begin: FractionalOffset.topLeft,
                                end: FractionalOffset.bottomRight),
                            borderRadius: BorderRadius.circular(40)),
                        padding: EdgeInsets.all(12),
                        child: Image.asset(
                          "assets/images/send.png",
                          height: 25,
                          width: 25,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getUserInfo() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    QuerySnapshot userdata =
        await DatabaseMethods().getUserInfo(auth.currentUser.email);
    currentUserName = userdata.docs[0]['userId'];
    print(userdata.docs[0]['userId']);
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe
                  ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                  : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)],
            )),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
