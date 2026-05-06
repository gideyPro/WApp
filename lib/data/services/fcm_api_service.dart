import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';

class FcmApiService {
  final ApiClient _apiClient;

  FcmApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<bool> registerToken(String token) async {
    try {
      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'web');
      
      final response = await _apiClient.dio.post(
        ApiConstants.registerFcmToken,
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
