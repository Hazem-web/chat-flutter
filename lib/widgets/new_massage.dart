import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMassage extends StatefulWidget {
  const new({super.key});

  @override
  State<NewMassage> createState() => _NewMassageState();
}

class _NewMassageState extends State<NewMassage> {
  final _controller = TextEditingController(text: '');

  void _sendMassage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await (FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get());
    await FirebaseFirestore.instance.collection('chat').add({
      'text': _controller.text,
      'createdAt': Timestamp.now(),
      'userId': user?.uid,
      'username': userData['username'],
      'userImage': userData['image_url'],
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: 'Send a massage...'),
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  _controller.text = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _controller.text.isEmpty ? null : _sendMassage,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
