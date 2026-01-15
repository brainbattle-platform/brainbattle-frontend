import '../../data/community_di.dart';

/// Get or create a DM conversation with a user.
/// 
/// If a DM already exists with the user, returns its threadId.
/// If not, creates a new DM conversation and returns the new threadId.
/// 
/// Throws an exception if the API call fails.
Future<String> getOrCreateDMConversation(String userId) async {
  final repo = communityRepo();
  
  // Try to get existing conversations
  try {
    final threads = await repo.getThreads(type: 'dm', limit: 100);
    
    // Find DM with this user
    for (final thread in threads.items) {
      // DM has exactly 2 participants (current user + target user)
      if (!thread.isClan && 
          thread.participants.length == 2 &&
          thread.participants.any((p) => p.id == userId)) {
        return thread.id;
      }
    }
  } catch (_) {
    // Silently continue to creation
  }
  
  // Create new DM
  final threadId = await repo.ensureDmThread(userId);
  return threadId;
}