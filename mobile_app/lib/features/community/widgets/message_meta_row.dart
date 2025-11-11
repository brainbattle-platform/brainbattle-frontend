import 'package:flutter/material.dart';
import '../data/models.dart';

class MessageMetaRow extends StatelessWidget {
  final Message msg;
  const MessageMetaRow({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final time =
        '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}';
    final (icon, color) = _statusIcon(msg);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(width: 6),
        if (icon != null) Icon(icon, size: 16, color: color),
      ],
    );
  }

  (IconData?, Color?) _statusIcon(Message m) {
    switch (m.status) {
      case MessageStatus.sending:
        return (Icons.access_time_rounded, Colors.grey);
      case MessageStatus.sent:
        return (Icons.check_rounded, Colors.grey);
      case MessageStatus.delivered:
        return (Icons.done_all_rounded, Colors.grey);
      case MessageStatus.read:
        return (Icons.done_all_rounded, Colors.blueAccent);
      case MessageStatus.failed:
        return (Icons.error_outline_rounded, Colors.redAccent);
    }
  }
}
