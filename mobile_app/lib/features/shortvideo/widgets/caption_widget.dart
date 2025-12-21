import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../shortvideo_routes.dart';

/// Widget to display caption with expand/collapse and clickable hashtags
class CaptionWidget extends StatefulWidget {
  final String caption;
  final String? music;
  final String? source;
  final String? label;

  const CaptionWidget({
    super.key,
    required this.caption,
    this.music,
    this.source,
    this.label,
  });

  @override
  State<CaptionWidget> createState() => _CaptionWidgetState();
}

class _CaptionWidgetState extends State<CaptionWidget> {
  bool _expanded = false;
  static const int _maxLinesCollapsed = 2;

  List<TextSpan> _parseCaption(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'#\w+');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before hashtag
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(color: Colors.white70),
        ));
      }

      // Add clickable hashtag
      final hashtag = match.group(0)!;
      spans.add(TextSpan(
        text: hashtag,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.w600,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.pushNamed(
              context,
              ShortVideoRoutes.hashtag,
              arguments: {'tag': hashtag.substring(1)}, // Remove #
            );
          },
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(color: Colors.white70),
      ));
    }

    return spans.isEmpty
        ? [TextSpan(text: text, style: const TextStyle(color: Colors.white70))]
        : spans;
  }

  @override
  Widget build(BuildContext context) {
    final needsExpand = widget.caption.length > 100; // Simple heuristic

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.source != null && widget.label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.content_cut, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '${widget.source} · ${widget.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (widget.source != null && widget.label != null)
          const SizedBox(height: 8),
        if (widget.music != null) ...[
          Text(
            widget.music!,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
        ],
        RichText(
          maxLines: _expanded ? null : _maxLinesCollapsed,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          text: TextSpan(children: _parseCaption(widget.caption)),
        ),
        if (needsExpand)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? 'Thu gọn' : 'Xem thêm',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

