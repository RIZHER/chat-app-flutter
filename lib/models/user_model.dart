class UserModel {
  final int id;
  final String name;
  final String email;
  final String uniqueCode;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.uniqueCode,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      uniqueCode: json['unique_code'] ?? '',
      avatar: json['avatar'],
    );
  }
}