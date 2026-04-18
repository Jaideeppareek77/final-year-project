import '../constants/api_constants.dart';
import 'api_client.dart';

class PrescriptionService {
  final _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getPrescriptions({String? patientId, String? appointmentId, int page = 1}) async {
    final response = await _dio.get(ApiConstants.prescriptions, queryParameters: {
      if (patientId != null) 'patientId': patientId,
      if (appointmentId != null) 'appointmentId': appointmentId,
      'page': page,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createPrescription({
    required String patientId,
    String? appointmentId,
    required String diagnosis,
    required List<Map<String, dynamic>> medicines,
    String? notes,
    String? validUntil,
  }) async {
    final response = await _dio.post(ApiConstants.prescriptions, data: {
      'patientId': patientId,
      if (appointmentId != null) 'appointmentId': appointmentId,
      'diagnosis': diagnosis,
      'medicines': medicines,
      if (notes != null) 'notes': notes,
      if (validUntil != null) 'validUntil': validUntil,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPrescriptionById(String id) async {
    final response = await _dio.get('${ApiConstants.prescriptions}/$id');
    return response.data as Map<String, dynamic>;
  }
}
