class VitalModel {
  final String id;
  final String patientId;
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? heartRate;
  final double? temperature;
  final double? oxygenSaturation;
  final double? bloodSugar;
  final double? weight;
  final double? height;
  final String? notes;
  final DateTime recordedAt;

  const VitalModel({
    required this.id,
    required this.patientId,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.temperature,
    this.oxygenSaturation,
    this.bloodSugar,
    this.weight,
    this.height,
    this.notes,
    required this.recordedAt,
  });

  factory VitalModel.fromJson(Map<String, dynamic> json) {
    return VitalModel(
      id: json['_id'] as String,
      patientId: json['patientId'] as String,
      bloodPressureSystolic: (json['bloodPressureSystolic'] as num?)?.toDouble(),
      bloodPressureDiastolic: (json['bloodPressureDiastolic'] as num?)?.toDouble(),
      heartRate: (json['heartRate'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
      bloodSugar: (json['bloodSugar'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }
}
