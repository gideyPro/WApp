import 'dart:io';
import '../../core/network/api_client.dart';

class FcmApiService {
  final ApiClient _apiClient;

  FcmApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<bool> registerToken(String token) async {
    try {
      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'web');
      
      final response = await _apiClient.dio.post(
        '/fcm/register',
        data: {
          'token': token,
          'platform': platform,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
