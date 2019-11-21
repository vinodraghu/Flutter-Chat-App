import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser firebaseUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var textController = TextEditingController();
  String message;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    currentUser();
  }

  void currentUser() async {
    try {
      var user = await _auth.currentUser();
      if (user != null) {
        firebaseUser = user;
        print(firebaseUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

//  void getMessages() async {
//    final message = await _firestore.collection('message').getDocuments();
//
//    for (var messages in message.documents) {
//      print(messages.data);
//    }
//  }

  void getStreamMessages() async {
    await for (var snapshots in _firestore.collection('message').snapshots()) {
      for (var messages in snapshots.documents) {
        print(messages.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamWidget(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textController.clear();
                      _firestore
                          .collection('message')
                          .add({'text': message, 'user': firebaseUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('message').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageWidget = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['user'];
          final messageBubble = MessageBubble(
            messageSender: messageSender,
            messageText: messageText,
            isMe: messageSender == firebaseUser.email,
          );
          messageWidget.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageWidget,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.messageSender, this.messageText, this.isMe});

  final String messageText;
  final String messageSender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            messageSender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe == true
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            elevation: 5.0,
            color: isMe == true ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$messageText',
                style: TextStyle(
                  color: isMe == true ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
