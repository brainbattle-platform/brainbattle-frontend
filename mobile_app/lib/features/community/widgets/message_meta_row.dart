import 'package:flutter/material.dart';
import '../../community/data/models.dart';
import '../ui/_helpers/datetime_helper.dart';

class MessageMetaRow extends StatelessWidget {
  final Message msg;
  final bool fromMe;
  final String? seenByText; // "Seen by Linh, Vy, +2"

  const MessageMetaRow({
    super.key,
    required this.msg,
    required this.fromMe,
    this.seenByText,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // Convert UTC timestamp to local time
    final localTime = parseToLocal(msg.createdAt.toIso8601String());
    final timeStr =
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    String statusStr = '';
    switch (msg.status) {
      case MessageStatus.sending:
        statusStr = 'Sending…';
        break;
      case MessageStatus.sent:
        statusStr = 'Sent';
        break;
      case MessageStatus.delivered:
        statusStr = 'Delivered';
        break;
      case MessageStatus.read:
        statusStr = 'Seen';
        break;
      case MessageStatus.failed:
        statusStr = 'Failed';
        break;
    }


    final base = '$timeStr · $statusStr';

    return Text(
      seenByText != null && fromMe
          ? '$base · $seenByText'
          : base,
      style: text.labelSmall?.copyWith(
        color: Colors.white54,
        fontSize: 11,
      ),
    );
  }
}
