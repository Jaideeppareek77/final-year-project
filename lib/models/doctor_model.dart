class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String? profilePhoto;
  final String? phone;
  final String? address;
  final String? bio;
  final String specialization;
  final String? specification;
  final double rating;
  final String openHour;
  final String closeHour;
  final double consultationFee;
  final int yearsExperience;
  final bool isAvailable;
  final List<String> languages;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
    this.phone,
    this.address,
    this.bio,
    required this.specialization,
    this.specification,
    required this.rating,
    required this.openHour,
    required this.closeHour,
    required this.consultationFee,
    required this.yearsExperience,
    required this.isAvailable,
    required this.languages,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    // GET /api/doctors/:id returns doctor fields nested under 'doctorProfile'
    // GET /api/doctors list returns fields flat — handle both
    final doc = json['doctorProfile'] as Map<String, dynamic>? ?? json;
    return DoctorModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      specialization: doc['specialization'] as String? ?? 'general',
      specification: doc['specification'] as String?,
      rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
      openHour: doc['openHour'] as String? ?? '09:00',
      closeHour: doc['closeHour'] as String? ?? '21:00',
      consultationFee: (doc['consultationFee'] as num?)?.toDouble() ?? 500,
      yearsExperience: doc['yearsExperience'] as int? ?? 0,
      isAvailable: doc['isAvailable'] as bool? ?? true,
      languages: (doc['languages'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
