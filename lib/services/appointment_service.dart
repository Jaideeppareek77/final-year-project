import '../constants/api_constants.dart';
import 'api_client.dart';

class AppointmentService {
  final _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getAppointments({
    String? status,
    int page = 1,
    int limit = 20,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.get(ApiConstants.appointments, queryParameters: {
      if (status != null) 'status': status,
      'page': page,
      'limit': limit,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createAppointment({
    required String doctorId,
    required String date,
    required String phone,
    String? description,
  }) async {
    final response = await _dio.post(ApiConstants.appointments, data: {
      'doctorId': doctorId,
      'date': date,
      'phone': phone,
      'description': description ?? '',
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAppointment(String id, {
    required String status,
    String? notes,
    String? cancelReason,
  }) async {
    final response = await _dio.put('${ApiConstants.appointments}/$id', data: {
      'status': status,
      if (notes != null) 'notes': notes,
      if (cancelReason != null) 'cancelReason': cancelReason,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteAppointment(String id) async {
    await _dio.delete('${ApiConstants.appointments}/$id');
  }
}
