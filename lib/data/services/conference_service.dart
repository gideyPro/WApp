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
        final conferences = (response.data['data'] as List)
            .map((json) => Conference.fromJson(json))
            .toList();

        return ConferenceResponse(
          success: true,
          conferences: conferences,
        );
      }

      return ConferenceResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch conferences',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Check for incoming calls
  Future<IncomingCallResponse> checkIncomingCall() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.checkIncomingCall,
      );

      if (response.statusCode == 200 && response.data['incoming'] == true) {
        // Backend returns all call fields at the top level (not nested under 'data')
        // Fields: incoming, conference_id, caller_name, caller_avatar,
        //         caller_initials, listing_title
        return IncomingCallResponse(
          success: true,
          hasIncoming: true,
          callData: Map<String, dynamic>.from(response.data as Map),
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
          if (participantIds != null) 'participant_ids': participantIds,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final conference = response.data['data'] != null
            ? Conference.fromJson(response.data['data'])
            : null;

        return ConferenceResponse(
          success: true,
          conference: conference,
          message: 'Conference created',
          jitsiRoomUrl: response.data['jitsi_url'],
          jitsiToken: response.data['jitsi_token'],
        );
      }

      return ConferenceResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to create conference',
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
        final conference = response.data['data'] != null
            ? Conference.fromJson(response.data['data'])
            : null;

        return ConferenceResponse(
          success: true,
          conference: conference,
          jitsiRoomUrl: response.data['jitsi_url'],
          jitsiToken: response.data['jitsi_token'],
        );
      }

      return ConferenceResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to start call',
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
        final conference = Conference.fromJson(
          response.data['data'] ?? response.data,
        );

        return ConferenceResponse(
          success: true,
          conference: conference,
          jitsiRoomUrl: response.data['jitsi_url'],
          jitsiToken: response.data['jitsi_token'],
        );
      }

      return ConferenceResponse(
        success: false,
        message: response.data['message'] ?? 'Conference not found',
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

      if (response.statusCode == 200) {
        return ConferenceResponse(
          success: true,
          message: 'Joined conference',
          jitsiRoomUrl: response.data['jitsi_url'],
          jitsiToken: response.data['jitsi_token'],
        );
      }

      return ConferenceResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to join conference',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConferenceResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Update conference status
  Future<ConferenceResponse> updateConferenceStatus({
    required int conferenceId,
    required String status, // active, ended
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConstants.updateConferenceStatus}/$conferenceId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return ConferenceResponse(
          success: true,
          message: 'Conference status updated',
        );
      }

      return ConferenceResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to update status',
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
          message: response.data['message'] ?? 'Conference ended',
        );
      }

      return ConferenceResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to end conference',
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
          message: response.data['message'] ?? 'User invited',
        );
      }

      return ConferenceResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to invite user',
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

  const ConferenceResponse({
    required this.success,
    this.message = '',
    this.conferences = const [],
    this.conference,
    this.jitsiRoomUrl,
    this.jitsiToken,
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
