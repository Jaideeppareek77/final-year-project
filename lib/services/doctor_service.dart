import '../constants/api_constants.dart';
import 'api_client.dart';

class DoctorService {
  final _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getDoctors({
    String? search,
    String? specialization,
    double? minRating,
    String sortBy = 'rating',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(ApiConstants.doctors, queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (specialization != null) 'specialization': specialization,
      if (minRating != null) 'minRating': minRating,
      'sortBy': sortBy,
      'page': page,
      'limit': limit,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDoctorById(String id) async {
    final response = await _dio.get('${ApiConstants.doctors}/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateDoctorProfile(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('${ApiConstants.doctors}/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSlots(String doctorId, String date) async {
    final url = '/api/doctors/$doctorId/slots';
    final response = await _dio.get(url, queryParameters: {'date': date});
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateAvailability(String doctorId, List<Map<String, dynamic>> availability) async {
    final url = '/api/doctors/$doctorId/availability';
    await _dio.put(url, data: {'availability': availability});
  }

  Future<Map<String, dynamic>> rateDoctor(String doctorId, double rating) async {
    final response = await _dio.post('/api/doctors/$doctorId/rate', data: {'rating': rating});
    return response.data as Map<String, dynamic>;
  }
}
