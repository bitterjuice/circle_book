import 'package:circle_book/widgets/chat_bubble_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Messages extends StatelessWidget {
  final String groupId;
  const Messages({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('GroupChats')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return ChatBubbles(
                userId: chatDocs[index]['userID'],
                message: chatDocs[index]['text'],
                isMe: chatDocs[index]['userID'].toString() ==
                    FirebaseAuth.instance.currentUser?.uid,
                image: chatDocs[index]['type'] == 1
                    ? chatDocs[index]['image']
                    : 'noImage');
          },
        );
      },
    );
  }
}
