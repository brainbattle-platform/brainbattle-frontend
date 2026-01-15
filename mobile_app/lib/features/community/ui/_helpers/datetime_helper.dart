/// DateTime helper for consistent timezone handling
/// 
/// Backend returns UTC timestamps (ISO 8601 with 'Z' suffix).
/// Frontend must convert all timestamps to local device time.

/// Parse ISO 8601 UTC string to local DateTime
/// 
/// Example:
/// - Input: "2025-01-15T10:30:00.000Z" (UTC)
/// - Output: DateTime in local timezone (e.g., UTC+7 Vietnam)
DateTime parseToLocal(String isoString) {
  return DateTime.parse(isoString).toLocal();
}

/// Format DateTime for display in chat queue
/// Shows time like "2m", "1h", "Yesterday", etc.
String formatChatTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    // Format as date: "Jan 15"
    return '${_monthName(dateTime.month)} ${dateTime.day}';
  }
}

/// Format DateTime for display in message bubbles
/// Shows time like "10:30 AM" or "Yesterday 2:30 PM"
String formatMessageTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final timeStr = '$hour:$minute';

  if (difference.inDays == 0 && dateTime.day == now.day) {
    // Same day: just show time
    return timeStr;
  } else if (difference.inDays == 1) {
    // Yesterday
    return 'Yesterday $timeStr';
  } else if (difference.inDays < 7) {
    // This week: show day name
    final dayName = _dayName(dateTime.weekday);
    return '$dayName $timeStr';
  } else {
    // Older: show date
    return '${_monthName(dateTime.month)} ${dateTime.day} $timeStr';
  }
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}

String _dayName(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}
