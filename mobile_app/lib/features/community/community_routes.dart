class CommunityRoutes {
  static const shell  = '/community';
  static const rooms  = '/community/rooms';
  static const dm     = '/community/dm';
  static const newClan = '/community/new-clan';
  static const thread = '/community/thread';
}

class ThreadArgs {
  final String threadId;
  final String? title;
  const ThreadArgs(this.threadId, {this.title});
}
