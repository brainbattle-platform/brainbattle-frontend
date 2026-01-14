import '../../../core/network/user_api.dart';
import 'user_profile.dart';

class UserRepository {
  final UserApi _api = UserApi();

  Future<UserProfile> getUserProfile(String userId) async {
    final json = await _api.getUserProfile(userId);
    return UserProfile.fromJson(json);
  }

  Future<List<UserProfile>> getFollowers(String userId, {int skip = 0, int take = 20}) async {
    final json = await _api.getFollowers(userId, skip: skip, take: take);
    return (json['data'] as List).map((e) => UserProfile.fromJson(e)).toList();
  }

  Future<List<UserProfile>> getFollowing(String userId, {int skip = 0, int take = 20}) async {
    final json = await _api.getFollowing(userId, skip: skip, take: take);
    return (json['data'] as List).map((e) => UserProfile.fromJson(e)).toList();
  }
}
