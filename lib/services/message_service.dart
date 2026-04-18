import '../constants/api_constants.dart';
import 'api_client.dart';

class MessageService {
  final _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final response = await _dio.post(ApiConstants.messages, data: {
      'receiverId': receiverId,
      'message': message,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pollMessages({
    required String withUserId,
    String? after,
    int limit = 50,
  }) async {
    final response = await _dio.get(ApiConstants.messages, queryParameters: {
      'with': withUserId,
      if (after != null) 'after': after,
      'limit': limit,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getConversations() async {
    final response = await _dio.get(ApiConstants.conversations);
    return response.data['conversations'] as List<dynamic>;
  }
}
