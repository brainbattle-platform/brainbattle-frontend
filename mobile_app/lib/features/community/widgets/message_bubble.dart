import 'package:flutter/material.dart';
import '../data/models.dart';
import 'message_meta_row.dart';

class MessageBubble extends StatelessWidget {
  final Message msg;
  final bool fromMe;
  final bool showAvatar;
  final bool showSenderName; // dùng cho clan
  final String? seenByText;  // dùng cho group "Seen by ..."

  const MessageBubble({
    super.key,
    required this.msg,
    required this.fromMe,
    this.showAvatar = true,
    this.showSenderName = false,
    this.seenByText,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final avatar = CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFF443A5B),
      backgroundImage:
          (msg.sender?.avatarUrl != null && msg.sender!.avatarUrl!.isNotEmpty)
              ? NetworkImage(msg.sender!.avatarUrl!)
              : null,
      child: (msg.sender?.avatarUrl == null ||
              msg.sender!.avatarUrl!.isEmpty)
          ? const Icon(Icons.person, color: Colors.white70, size: 18)
          : null,
    );

    final bubbleColor =
        fromMe ? const Color(0xFFF3B4C3) : const Color(0xFF2F2941);
    final textColor = fromMe ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!fromMe) ...[
            showAvatar ? avatar : const SizedBox(width: 32),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showSenderName && !fromMe) ...[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 4, right: 4, bottom: 2),
                    child: Text(
                      msg.sender?.displayName ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: fromMe
                            ? const Radius.circular(20)
                            : const Radius.circular(4),
                        bottomRight: fromMe
                            ? const Radius.circular(4)
                            : const Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: fromMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MessageMetaRow(
                          msg: msg,
                          fromMe: fromMe,
                          seenByText: seenByText,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
