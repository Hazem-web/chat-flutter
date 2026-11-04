import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'massage_bubble.dart';

class Massages extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs;
        return ListView.builder(
          reverse: true,
          itemCount: docs?.length,
          itemBuilder: ((con, index) {
            return MassageBubble(
              massage: docs?[index]['text'],
              isMe:
                  FirebaseAuth.instance.currentUser?.uid ==
                  docs?[index]['userId'],
              key: ValueKey(docs?[index].id),
              username: docs?[index]['username'],
              imageUrl: docs?[index]['userImage'],
            );
          }),
        );
      },
    );
  }
}
