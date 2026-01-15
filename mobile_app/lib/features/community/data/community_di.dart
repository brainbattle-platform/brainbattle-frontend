// lib/features/community/data/community_di.dart
import 'package:mobile_app/core/network/api_base.dart';
import 'community_api.dart';
import 'community_repository.dart';

// Global singleton repository
ICommunityRepository? _repository;

ICommunityRepository communityRepo() {
  if (_repository == null) {
    final api = CommunityApi(
      baseUrlMessaging: apiMessaging(),
      baseUrlCore: apiCore(),
      currentUserId: 'me', // MVP: no real auth yet
    );
    _repository = CommunityRepositoryHttp(api);
  }
  return _repository!;
}
