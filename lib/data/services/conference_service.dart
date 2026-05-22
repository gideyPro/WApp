import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';

/// Service for video conferences (Jitsi integration)
class ConferenceService {
  final ApiClient _apiClient;

  ConferenceService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get user's conferences
  Future<ConferenceResponse> getConferences() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.conferences);

      if (response.statusCode == 200) {
        final dataList = _extractList(response.data);
        final conferences = dataList
            .whereType<Map>()
            .map((json) => Conference.fromJson(json as Map<String, dynamic>))
            .toList();

        return ConferenceResponse(
          success: true,
          conferences: conferences,
        );
      }

      return ConferenceResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to fetch conferences'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Robustly extract a list from various API response structures
  List<dynamic> _extractList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw;
    if (raw is Map) {
      final data = raw['data'];
      if (data is List) return data;
      if (data is Map) {
        final nestedData = data['data'] ?? data['conferences'] ?? data['items'];
        if (nestedData is List) return nestedData;
      }
      final directList = raw['conferences'] ?? raw['items'];
      if (directList is List) return directList;
    }
    return [];
  }

  /// Robustly extract a message from various API response structures
  String _extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map) {
      return raw['message']?.toString() ?? 
             raw['error']?.toString() ?? 
             raw['errors']?.toString() ?? 
             defaultMessage;
    }
    if (raw is String) return raw;
    return defaultMessage;
  }

  /// Check for incoming calls
  Future<IncomingCallResponse> checkIncomingCall() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.checkIncomingCall,
      );

      final raw = response.data;
      if (response.statusCode == 200 && raw is Map && raw['incoming'] == true) {
        // Backend returns all call fields at the top level (not nested under 'data')
        // Fields: incoming, conference_id, caller_name, caller_avatar,
        //         caller_initials, listing_title
        return IncomingCallResponse(
          success: true,
          hasIncoming: true,
          callData: Map<String, dynamic>.from(raw),
        );
      }

      return const IncomingCallResponse(
        success: true,
        hasIncoming: false,
      );
    } catch (e) {
      return const IncomingCallResponse(success: false, hasIncoming: false);
    }
  }

  /// Create conference for a listing
  Future<ConferenceResponse> createConference({
    required int listingId,
    List<int>? participantIds,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.createConference}/$listingId',
        data: {
          if (participantIds != null) 'buyer_ids': participantIds,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = response.data;
        Map<String, dynamic>? data;
        
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final conference = data != null ? Conference.fromJson(data) : null;

        return ConferenceResponse(
          success: true,
          conference: conference,
          message: 'Conference created',
          jitsiRoomUrl: data?['jitsi_url']?.toString(),
          jitsiToken: data?['jitsi_token']?.toString(),
        );
      }

      return ConferenceResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to create conference'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Start direct call from conversation
  Future<ConferenceResponse> startDirectCall({
    required int conversationId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.startDirectCall}/$conversationId',
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        Map<String, dynamic>? data;
        
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final conference = data != null ? Conference.fromJson(data) : null;

        return ConferenceResponse(
          success: true,
          conference: conference,
          jitsiRoomUrl: data?['jitsi_url']?.toString(),
          jitsiToken: data?['jitsi_token']?.toString(),
        );
      }

      return ConferenceResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to start call'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get conference details
  Future<ConferenceResponse> getConferenceDetail(int conferenceId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.conferenceDetail}/$conferenceId',
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        Map<String, dynamic>? data;
        
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final conference = data != null ? Conference.fromJson(data) : null;

        return ConferenceResponse(
          success: true,
          conference: conference,
          jitsiRoomUrl: data?['jitsi_url']?.toString(),
          jitsiToken: data?['jitsi_token']?.toString(),
        );
      }

      return ConferenceResponse(
        success: false,
        message: _extractMessage(response.data, 'Conference not found'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Join conference
  Future<ConferenceResponse> joinConference(int conferenceId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.joinConference}/$conferenceId/join',
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        
        // Handle unexpected response types gracefully
        if (responseData is! Map) {
          return ConferenceResponse(
            success: false,
            message: 'Invalid response format from server',
            rawData: responseData,
          );
        }

        final Map<String, dynamic> rootData = Map<String, dynamic>.from(responseData);

        // Backend returns {success: true, data: {jitsi_url: ..., ...}}
        // Need to look inside rootData['data'] for jitsi_url
        final Map<String, dynamic> data = rootData['data'] is Map
            ? Map<String, dynamic>.from(rootData['data'] as Map)
            : <String, dynamic>{};

        final jitsiUrl = data['jitsi_url']?.toString();
        final jitsiToken = data['jitsi_token']?.toString();

        return ConferenceResponse(
          success: true,
          message: 'Joined conference',
          jitsiRoomUrl: jitsiUrl,
          jitsiToken: jitsiToken,
          rawData: rootData,
        );
      }

      return ConferenceResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to join conference'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Delete/end conference
  Future<ConferenceResponse> deleteConference(int conferenceId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.deleteConference}/$conferenceId',
      );

      if (response.statusCode == 200) {
        return ConferenceResponse(
          success: true,
          message: _extractMessage(response.data, 'Conference ended'),
        );
      }

      return ConferenceResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to end conference'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Invite user to conference
  Future<ConferenceResponse> inviteUser({
    required int conferenceId,
    required int userId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.inviteToConference}/$conferenceId/invite/$userId',
      );

      if (response.statusCode == 200) {
        return ConferenceResponse(
          success: true,
          message: _extractMessage(response.data, 'User invited'),
        );
      }

      return ConferenceResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to invite user'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Ping conference (keep-alive)
  Future<bool> pingConference(int conferenceId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.pingConference}/$conferenceId/ping',
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Response wrapper for conference operations
class ConferenceResponse {
  final bool success;
  final String message;
  final List<Conference> conferences;
  final Conference? conference;
  final String? jitsiRoomUrl;
  final String? jitsiToken;
  final dynamic rawData;

  const ConferenceResponse({
    required this.success,
    this.message = '',
    this.conferences = const [],
    this.conference,
    this.jitsiRoomUrl,
    this.jitsiToken,
    this.rawData,
  });
}

/// Response for incoming call check
class IncomingCallResponse {
  final bool success;
  final bool hasIncoming;
  final Map<String, dynamic>? callData;

  const IncomingCallResponse({
    required this.success,
    required this.hasIncoming,
    this.callData,
  });
}

/// Conference model
class Conference {
  final int id;
  final String roomName;
  final String status;
  final String? startedAt;
  final String? endedAt;
  final int listingId;
  final int initiatorId;

  const Conference({
    required this.id,
    required this.roomName,
    required this.status,
    this.startedAt,
    this.endedAt,
    required this.listingId,
    required this.initiatorId,
  });

  factory Conference.fromJson(Map<String, dynamic> json) {
    return Conference(
      id: json['id'] ?? 0,
      roomName: json['room_name'] ?? '',
      status: json['status'] ?? 'pending',
      startedAt: json['started_at'],
      endedAt: json['ended_at'],
      listingId: json['listing_id'] ?? 0,
      initiatorId: json['initiator_id'] ?? 0,
    );
  }

  bool get isActive => status == 'active';
  bool get isEnded => status == 'ended';
}
