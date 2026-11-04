import 'package:flutter/material.dart';

class MassageBubble extends StatelessWidget {
  const MassageBubble({
    super.key,
    required this.massage,
    required this.isMe,
    required this.username,
    required this.imageUrl,
  });
  final String massage;
  final String imageUrl;
  final String username;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: .none,
      children: [
        Row(
          key: key,
          mainAxisAlignment: isMe ? .end : .start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.grey[300]
                    : Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              width: 120,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                crossAxisAlignment: isMe ? .end : .start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: .bold,
                      color: isMe
                          ? Colors.black
                          : Theme.of(context).textTheme.titleSmall?.color,
                    ),
                  ),
                  Text(
                    massage,
                    style: TextStyle(
                      color: isMe
                          ? Colors.black
                          : Theme.of(context).textTheme.titleSmall?.color,
                    ),
                    textAlign: isMe ? .end : .start,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: isMe ? null : 120,
          right: isMe ? 120 : null,
          child: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
        ),
      ],
    );
  }
}
