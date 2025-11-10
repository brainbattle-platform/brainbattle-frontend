/// Hợp đồng làm việc với tầng dữ liệu (BE)
abstract class AuthRepository {
  Future<bool> login({required String email, required String password});
  // Sau này bổ sung:
  // Future<void> logout();
  // Future<TokenPair> refresh(String refreshToken);
  // Future<UserMe> me(String accessToken);
}

/// Triển khai stub tạm thời, chưa gọi BE
class AuthRepositoryStub implements AuthRepository {
  @override
  Future<bool> login({required String email, required String password}) async {
    // Fake network
    await Future.delayed(const Duration(milliseconds: 800));

    // Logic giả cho demo form
    if (email.endsWith('@example.com') && password.length >= 6) {
      return true;
    }
    throw Exception('Invalid email or password (stub)');
  }
}
