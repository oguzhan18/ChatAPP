// ignore_for_file: prefer_const_constructors

import './welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';
import 'welcome_screen.dart';

final Stream<QuerySnapshot> _messagesStream = FirebaseFirestore.instance
    .collection('messages')
    .orderBy('Timestamp', descending: true)
    .snapshots();
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const String id = 'chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();

  late String messageText;
  bool disabledButton = true;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    WelcomeScreen.id, (route) => false);
              }),
        ],
        title: Text('AIFA CHAT'),
        backgroundColor: Colors.grey[800],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: MessagesStream(),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        (value.isNotEmpty)
                            ? disabledButton = false
                            : disabledButton = true;
                        setState(() {});
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    child: (disabledButton)
                        ? kSendButtonStyleDisabled
                        : kSendButtonStyleEnabled,
                    onPressed: (disabledButton)
                        ? null
                        : () {
                            firestore.collection('messages').add({
                              'text': messageText,
                              'sender': loggedInUser.email,
                              'Timestamp': FieldValue.serverTimestamp()
                            });
                            setState(() {
                              disabledButton = true;
                              messageTextController.clear();
                            });
                          },
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

class MessagesStream extends StatelessWidget {
  const MessagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _messagesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return ListView(
          reverse: true,
          shrinkWrap: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> messages =
                document.data()! as Map<String, dynamic>;
            List<MessageBubble> messageBubbles = [];
            final messageText = messages['text'];
            final messageSender = messages['sender'];
            final currentUser = loggedInUser.email;
            final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageBubble);
            return Column(
              crossAxisAlignment: (currentUser == messageSender)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: messageBubbles,
            );
          }).toList(),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {Key? key, required this.text, required this.sender, required this.isMe})
      : super(key: key);
  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: (isMe)
          ? EdgeInsets.only(left: 10, top: 7, right: 70, bottom: 10)
          : EdgeInsets.only(left: 70, top: 7, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment:
            (isMe) ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            sender,
            style: TextStyle(
                fontSize: 12, color: (isMe) ? Colors.white54 : Colors.blue),
          ),
          Material(
            elevation: 5,
            borderRadius: (isMe)
                ? BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15))
                : BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15)),
            shadowColor: Colors.grey,
            color: (isMe) ? Colors.blueGrey[800] : Colors.blue[400],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                text,
                style: TextStyle(
                    color: (isMe) ? Colors.white70 : Colors.black,
                    fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
