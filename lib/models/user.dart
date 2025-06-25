class User {
  final String id;
  final String name;
  final String email;
  final String? profileImagePath;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImagePath,
    required this.createdAt,
    required this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImagePath': profileImagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImagePath: json['profileImagePath'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(json['lastLoginAt']),
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? profileImagePath,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
