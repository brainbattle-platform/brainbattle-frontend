import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
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
                        if (msg.attachments.isNotEmpty) ...[
                          _AttachmentList(
                            attachments: msg.attachments,
                            fromMe: fromMe,
                          ),
                          if (msg.text.isNotEmpty)
                            const SizedBox(height: 6),
                        ],
                        if (msg.text.isNotEmpty)
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

class _AttachmentList extends StatelessWidget {
  final List<Attachment> attachments;
  final bool fromMe;

  const _AttachmentList({
    required this.attachments,
    required this.fromMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: attachments
          .map((att) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildAttachment(att),
              ))
          .toList(),
    );
  }

  Widget _buildAttachment(Attachment att) {
    switch (att.type) {
      case 'image':
        return _ImageAttachment(att: att);
      case 'file':
        return _FileAttachment(att: att);
      case 'link':
        return _LinkAttachment(att: att);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ImageAttachment extends StatelessWidget {
  final Attachment att;

  const _ImageAttachment({required this.att});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        (att.thumbnailUrl != null && att.thumbnailUrl!.isNotEmpty)
            ? att.thumbnailUrl!
            : att.url;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 200,
          height: 120,
          color: Colors.black12,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 120,
          color: Colors.black26,
          child: const Icon(Icons.broken_image, color: Colors.white70),
        ),
      ),
    );
  }
}

class _FileAttachment extends StatelessWidget {
  final Attachment att;

  const _FileAttachment({required this.att});

  String _formatSize(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    }
    if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    final name = att.fileName ?? 'Attachment';
    final sizeLabel =
        att.sizeBytes != null ? _formatSize(att.sizeBytes!) : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.insert_drive_file, size: 18, color: Colors.white70),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (sizeLabel != null)
                Text(
                  sizeLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkAttachment extends StatelessWidget {
  final Attachment att;

  const _LinkAttachment({required this.att});

  Future<void> _openLink() async {
    final uri = Uri.tryParse(att.url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openLink,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 18, color: Colors.white70),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              att.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
