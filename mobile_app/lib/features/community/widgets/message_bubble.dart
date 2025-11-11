import 'package:flutter/material.dart';
import '../data/models.dart';
import 'message_meta_row.dart';

class MessageBubble extends StatelessWidget {
  final Message msg;
  final bool fromMe;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.msg,
    required this.fromMe,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final main = fromMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final cross = fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final avatar = CircleAvatar(
      radius: 18,
      backgroundImage: (msg.sender.avatarUrl != null)
          ? NetworkImage(msg.sender.avatarUrl!)
          : const AssetImage('assets/images/default_user.png') as ImageProvider,
    );

    // Giới hạn bề rộng bubble ~72% màn hình, không chạm viền/đè avatar
    final maxBubble = MediaQuery.of(context).size.width * 0.72;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      child: Row(
        mainAxisAlignment: main,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!fromMe) ...[
            showAvatar ? avatar : const SizedBox(width: 36),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubble),
              child: Container(
                decoration: BoxDecoration(
                  color: fromMe ? const Color(0xFFF7D8E1) : const Color(0xFF3A3150),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(fromMe ? 16 : 4),
                    bottomRight: Radius.circular(fromMe ? 4 : 16),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: cross,
                  children: [
                    // (nếu là group và muốn show tên người gửi: bật thêm đoạn dưới)
                    // if (!fromMe) Padding(
                    //   padding: const EdgeInsets.only(bottom: 2),
                    //   child: Text(msg.sender.name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    // ),
                    Text(
                      msg.text,
                      softWrap: true,
                      style: TextStyle(color: fromMe ? Colors.black : Colors.white, height: 1.25),
                    ),
                    const SizedBox(height: 4),
                    MessageMetaRow(msg: msg),
                  ],
                ),
              ),
            ),
          ),
          if (fromMe) ...[
            const SizedBox(width: 6),
            showAvatar ? avatar : const SizedBox(width: 36),
          ],
        ],
      ),
    );
  }
}
