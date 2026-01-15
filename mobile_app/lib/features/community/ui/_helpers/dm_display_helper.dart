import '../../data/models.dart';

/// Get the display name and avatar for a DM (direct message) thread.
/// 
/// For DM conversations, we display the other participant's info,
/// NOT the thread.title.
/// 
/// Returns: (displayName, avatarUrl)
(String displayName, String? avatarUrl) getDMCounterpartInfo(ThreadLiteApi thread) {
  if (thread.isClan) {
    // This is not a DM, return thread title
    return (thread.title, thread.avatarUrl);
  }

  // For DMs, find the counterpart (other participant)
  // Current user is always "me"
  final counterpart = thread.participants.firstWhere(
    (p) => p.id != 'me',
    orElse: () => thread.participants.isNotEmpty
        ? thread.participants[0]
        : UserLite(
            id: 'unknown',
            handle: 'unknown',
            displayName: thread.title,
          ),
  );

  // Display name with fallback to handle
  final displayName = counterpart.displayName.isNotEmpty
      ? counterpart.displayName
      : '@${counterpart.handle}';

  return (displayName, counterpart.avatarUrl);
}

/// Get just the display name for a DM thread
String getDMCounterpartName(ThreadLiteApi thread) {
  final (displayName, _) = getDMCounterpartInfo(thread);
  return displayName;
}

/// Get just the avatar URL for a DM thread
String? getDMCounterpartAvatar(ThreadLiteApi thread) {
  final (_, avatarUrl) = getDMCounterpartInfo(thread);
  return avatarUrl;
}
