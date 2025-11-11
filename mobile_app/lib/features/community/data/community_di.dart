// lib/features/community/data/community_di.dart
import 'package:mobile_app/core/network/api_base.dart';
import 'community_api.dart';
import 'community_repository.dart';

ICommunityRepository provideCommunityRepository({bool useFake = true}) {
  if (useFake) return CommunityRepositoryFake();
  final base = apiBase(); // ví dụ: 'http://192.168.1.34:3000'
  final api = CommunityApi(baseUrl: base, tokenProvider: () async => null); // TODO: lấy token thật
  return CommunityRepositoryHttp(api);
}
