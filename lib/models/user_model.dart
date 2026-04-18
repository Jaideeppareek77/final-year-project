class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profilePhoto;
  final String? phone;
  final String? address;
  final String? bio;
  final String? birthDate;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhoto,
    this.phone,
    this.address,
    this.bio,
    this.birthDate,
  });

  bool get isDoctor => role == 'doctor';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      birthDate: json['birthDate'] as String?,
    );
  }
}
