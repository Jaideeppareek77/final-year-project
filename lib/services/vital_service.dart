import '../constants/api_constants.dart';
import 'api_client.dart';

class VitalService {
  final _dio = ApiClient.instance.dio;

  Future<List<dynamic>> getVitals({String? patientId, String? from, String? to, int limit = 30}) async {
    final response = await _dio.get(ApiConstants.vitals, queryParameters: {
      if (patientId != null) 'patientId': patientId,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      'limit': limit,
    });
    return response.data['vitals'] as List<dynamic>;
  }

  Future<Map<String, dynamic>?> getLatestVitals({String? patientId}) async {
    final response = await _dio.get(ApiConstants.vitalsLatest, queryParameters: {
      if (patientId != null) 'patientId': patientId,
    });
    return response.data['vital'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> logVitals({
    String? patientId,
    double? bpSystolic,
    double? bpDiastolic,
    double? heartRate,
    double? temperature,
    double? oxygenSaturation,
    double? bloodSugar,
    double? weight,
    double? height,
    String? notes,
  }) async {
    final response = await _dio.post(ApiConstants.vitals, data: {
      if (patientId != null) 'patientId': patientId,
      if (bpSystolic != null) 'bloodPressureSystolic': bpSystolic,
      if (bpDiastolic != null) 'bloodPressureDiastolic': bpDiastolic,
      if (heartRate != null) 'heartRate': heartRate,
      if (temperature != null) 'temperature': temperature,
      if (oxygenSaturation != null) 'oxygenSaturation': oxygenSaturation,
      if (bloodSugar != null) 'bloodSugar': bloodSugar,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (notes != null) 'notes': notes,
      'recordedAt': DateTime.now().toIso8601String(),
    });
    return response.data as Map<String, dynamic>;
  }
}
