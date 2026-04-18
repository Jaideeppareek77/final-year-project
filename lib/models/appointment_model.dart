class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String phone;
  final String description;
  final DateTime date;
  final String status;
  final String? cancelReason;
  final String? notes;
  final DateTime createdAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.phone,
    required this.description,
    required this.date,
    required this.status,
    this.cancelReason,
    this.notes,
    required this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['_id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      patientName: json['patientName'] as String,
      doctorName: json['doctorName'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      cancelReason: json['cancelReason'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
