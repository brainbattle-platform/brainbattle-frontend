class AuthUser {
  final String id;
  final String? username;
  final String? displayName;

  AuthUser({
    required this.id,
    this.username,
    this.displayName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['userId'] as String? ?? json['id'] as String? ?? '',
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'username': username,
      'displayName': displayName,
    };
  }
}

